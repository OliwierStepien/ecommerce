import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/core/network/network_info.dart';

/// Główna klasa odpowiedzialna za synchronizację danych między lokalną bazą Hive a Firebase
class PlannedMealSyncService implements SyncService {
  // Repozytorium Firebase do operacji zdalnych
  final FirebasePlannedMealRepositoryImpl firebaseRepo;
  
  // Repozytorium Hive do operacji lokalnych
  final HivePlannedMealRepositoryImpl hiveRepo;
  
  // Serwis do sprawdzania połączenia internetowego
  final NetworkInfo networkInfo;

  /// Konstruktor przyjmujący wymagane zależności
  PlannedMealSyncService({
    required this.firebaseRepo,
    required this.hiveRepo,
    required this.networkInfo,
  });

  /// Główna metoda synchronizująca dane
  @override
  Future<Either<Failure, void>> syncData() async {
    // 1. Sprawdzenie czy urządzenie jest online
    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure()); // Zwróć błąd jeśli brak internetu
    }

    // 2. Pobierz niezsynchronizowane zmiany z lokalnej bazy Hive
    final changesResult = await hiveRepo.getUnsyncedChangesForPlannedMeals();
    
    // 3. Obsłuż wynik operacji
    return changesResult.fold(
      // Jeśli wystąpił błąd - przekaż go dalej
      (failure) => Left(failure),
      
      // Jeśli sukces - przetwarzaj zmiany
      (changes) async {
        // Otwórz Box Hive do operacji na danych
        final box = Hive.box<PlannedMealModel>('plannedMeals');
        
        // 4. Przetwarzaj każdą niezsynchronizowaną zmianę
        for (final entity in changes) {
          // Generuj unikalny klucz dla posiłku (data + ID posiłku)
          final key = '${entity.date}_${entity.meal.mealId}';
          
          // Pobierz model z bazy lokalnej
          final model = box.get(key);
          
          // Pominięcie jeśli model nie istnieje
          if (model == null) continue;
          
          // 5. Obsługa usuniętych pozycji
          if (model.isDeleted) {
            // Wyślij żądanie usunięcia do Firebase
            final result = await firebaseRepo.removePlannedMeal(entity);
            
            // Jeśli błąd - przerwij i zwróć błąd
            if (result.isLeft()) {
              return Left((result as Left).value);
            }
            
            // Jeśli sukces - usuń całkowicie z Hive
            await box.delete(key);
          } 
          // 6. Obsługa dodanych/zmodyfikowanych pozycji
          else {
            // Wyślij dane do Firebase
            final result = await firebaseRepo.addPlannedMeal(entity);
            
            // Jeśli błąd - przerwij i zwróć błąd
            if (result.isLeft()) {
              return Left((result as Left).value);
            }
            
            // Jeśli sukces - zaktualizuj status synchronizacji w Hive
            await box.put(key, PlannedMealModel(
              date: entity.date,
              meal: MealMapper.toModel(entity.meal), // Konwersja encji na model
              isSynced: true, // Oznacz jako zsynchronizowane
              isDeleted: false,
              position: model.position, // Zachowaj pozycję
            ));
          }
        }
        
        // 7. Zwróć sukces po przetworzeniu wszystkich zmian
        return const Right(null);
      },
    );
  }
    Future<Either<Failure, void>> removePlannedMealsInDateRange(
      DateTime start, DateTime end) async {
    // Usuń z Hive
    final localResult =
        await hiveRepo.removePlannedMealsInDateRange(start, end);
    if (localResult.isLeft()) return localResult;

    // Jeśli brak internetu — zakończ tutaj
    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) return const Right(null);

    // Usuń także z Firebase
    final remoteResult =
        await firebaseRepo.removePlannedMealsInDateRange(start, end);
    return remoteResult.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}