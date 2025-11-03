// core/sync/planned_meal_sync_service.dart
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';

class PlannedMealSyncService implements SyncService {
  final FirebasePlannedMealRepositoryImpl firebaseRepo;
  final HivePlannedMealRepositoryImpl hiveRepo;
  final NetworkInfo networkInfo;

  PlannedMealSyncService({
    required this.firebaseRepo,
    required this.hiveRepo,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> syncData() async {
    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure());
    }

    // --- PUSH: wyślij lokalne niezsynchronizowane zmiany do Firestore ---
    final changesResult = await hiveRepo.getUnsyncedChangesForPlannedMeals();
    final box = Hive.box<PlannedMealModel>('plannedMeals');

    final push = await changesResult.fold<Future<Either<Failure, void>>>(
      (failure) async => Left(failure),
      (changes) async {
        for (final entity in changes) {
          final key = '${entity.date}_${entity.meal.mealId}';
          final model = box.get(key);
          if (model == null) continue;

          if (model.isDeleted) {
            final res = await firebaseRepo.removePlannedMeal(entity);
            if (res.isLeft()) return Left((res as Left).value);
            await box.delete(key);
          } else {
            final res = await firebaseRepo.addPlannedMeal(entity);
            if (res.isLeft()) return Left((res as Left).value);
            await box.put(
              key,
              PlannedMealModel(
                date: entity.date,
                meal: MealMapper.toModel(entity.meal),
                isSynced: true,
                isDeleted: false,
                position: model.position,
              ),
            );
          }
        }
        return const Right(null);
      },
    );

    if (push.isLeft()) return push;

    // --- PULL: pobierz Firestore -> zapisz/uzgodnij w Hive ---
    final pullResult = await firebaseRepo.getPlannedMeals();
    return await pullResult.fold(
      (failure) async => Left(failure),
      (remoteEntities) async {
        // zbuduj mapę kluczy istniejących w Hive (po normalizacji klucza jak wszędzie)
        final existingKeys = box.keys.map((k) => k.toString()).toSet();

        for (final entity in remoteEntities) {
          final key = '${entity.date}_${entity.meal.mealId}';

          // Jeśli już istnieje w Hive – nadpisz tylko dany rekord aktualnym stanem zsynchronizowanym
          // (pozwala to dociągnąć udostępnione wpisy od znajomych)
          final current = box.get(key);
          await box.put(
            key,
            PlannedMealModel(
              date: entity.date,
              meal: MealMapper.toModel(entity.meal),
              position: current?.position ?? entity.position,
              isSynced: true,
              isDeleted: false,
            ),
          );

          existingKeys.remove(key);
        }

        // UWAGA: NIE kasujemy pozostałych rekordów z Hive.
        // Dzięki temu brak „masowego” czyszczenia, a udostępnione wpisy i lokalne pozostają.
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, void>> removePlannedMealsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final localResult = await hiveRepo.removePlannedMealsInDateRange(start, end);
    if (localResult.isLeft()) return localResult;

    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) return const Right(null);

    final remoteResult = await firebaseRepo.removePlannedMealsInDateRange(start, end);
    return remoteResult.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}