import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

/// Synchronizuje pozycje listy zakupów pomiędzy Hive (lokalnie) a Firestore (zdalnie).
/// Proces obejmuje:
/// 1. Sprawdzenie połączenia z internetem
/// 2. Usuwanie z Firestore pozycji oznaczonych jako usunięte (`isDeleted`)
/// 3. Dodawanie lub aktualizowanie pozostałych pozycji
/// 4. Oznaczanie ich jako zsynchronizowane (`isSynced`) lokalnie
class ShoppingListMealIngredientSyncService implements SyncService {
  final ShoppingListMealIngredientRepository _remoteRepo;
  final NetworkInfo _networkInfo;

  ShoppingListMealIngredientSyncService({
    required ShoppingListMealIngredientRepository remoteRepo,
    required NetworkInfo networkInfo,
  })  : _remoteRepo = remoteRepo,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> syncData() async {
    // 1) Sprawdź, czy urządzenie ma dostęp do internetu
    if (!await _networkInfo.checkInternetConnection()) {
      return Left(NetworkFailure());
    }

    // Otwórz lokalne pudełko Hive z modelami składników listy zakupów
    final box = Hive.box<ShoppingListMealIngredientModel>(
        'shoppingListMealIngredients');

    // Wybierz wszystkie modele, które nie zostały jeszcze zsynchronizowane
    final unsyncedModels = box.values.where((m) => !m.isSynced);

    // Podziel dane na:
    // a) elementy oznaczone jako usunięte (do zdalnego usunięcia)
    final deletedModels = unsyncedModels.where((m) => m.isDeleted).toList();

    // b) elementy, które nie są oznaczone do usunięcia (do dodania lub aktualizacji)
    final nonDeletedUnsyncedModels =
        _deduplicate(unsyncedModels.where((m) => !m.isDeleted));

    // 2) Najpierw usuń z Firestore modele oznaczone jako usunięte
    final deletionFailure = await _syncDeletedModels(deletedModels, box);
    if (deletionFailure != null) return Left(deletionFailure);

    // 3) Następnie dodaj lub zaktualizuj pozostałe modele w Firestore
    final addFailure = await _syncAdditions(nonDeletedUnsyncedModels, box);
    if (addFailure != null) return Left(addFailure);

    // Zakończ pomyślnie
    return const Right(null);
  }

  /* ---------- PRYWATNE METODY POMOCNICZE ---------- */

  /// Tworzy unikalny klucz dla modelu w formacie `<mealId>_<ingredientId>`,
  /// wykorzystywany zarówno w Hive, jak i Firestore jako identyfikator.
  String _modelKey(ShoppingListMealIngredientModel m) =>
      '${m.meal.mealId}_${m.ingredient.ingredientId}';

  /// Spośród wielu wersji tego samego składnika (dla tej samej pary `mealId` + `ingredientId`)
  /// wybiera tylko najnowszy — nadpisując starsze wpisy.
  List<ShoppingListMealIngredientModel> _deduplicate(
    Iterable<ShoppingListMealIngredientModel> models,
  ) {
    final map = <String, ShoppingListMealIngredientModel>{};
    for (final m in models) {
      // Nadpisuje wcześniejsze wpisy dla tego samego klucza
      map[_modelKey(m)] = m;
    }
    return map.values.toList();
  }

  /// Usuwa modele zdalnie (z Firestore), jeśli lokalnie oznaczono je jako `isDeleted`.
  /// Następnie usuwa je również lokalnie z Hive.
  Future<Failure?> _syncDeletedModels(
    List<ShoppingListMealIngredientModel> models,
    Box<ShoppingListMealIngredientModel> box,
  ) async {
    for (final m in models) {
      final result = await _remoteRepo.removeMealIngredientFromShoppingList(
        MealMapper.toEntity(m.meal),
        IngredientMapper.toEntity(m.ingredient),
      );

      // Jeśli wystąpił błąd, zakończ synchronizację niepowodzeniem
      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      // Usuń model również lokalnie (z Hive)
      await box.delete(_modelKey(m));
    }
    return null;
  }

  /// Dodaje lub aktualizuje modele w Firestore, a następnie oznacza je jako zsynchronizowane lokalnie.
  Future<Failure?> _syncAdditions(
    List<ShoppingListMealIngredientModel> models,
    Box<ShoppingListMealIngredientModel> box,
  ) async {
    for (final m in models) {
      final addResult = await _remoteRepo.addMealIngredientToShoppingList(
        MealMapper.toEntity(m.meal),
        IngredientMapper.toEntity(m.ingredient),
        m.portionCount,
      );

      // Jeśli wystąpił błąd, zakończ synchronizację niepowodzeniem
      final failure = _failureOrNull(addResult);
      if (failure != null) return failure;

      // Zaktualizuj model lokalnie:
      // - oznacz jako zsynchronizowany
      // - upewnij się, że `isDeleted` = false
      await box.put(
        _modelKey(m),
        m.copyWith(isSynced: true, isDeleted: false),
      );
    }
    return null;
  }

  /// Jeśli operacja zakończyła się błędem (`Left`), zwraca obiekt `Failure`.
  /// W przeciwnym razie zwraca `null`.
  Failure? _failureOrNull(Either<Failure, void> result) {
    return result.fold(
      (failure) => failure,
      (success) => null,
    );
  }
}