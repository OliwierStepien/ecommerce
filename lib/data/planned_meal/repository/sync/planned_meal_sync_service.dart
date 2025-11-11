// core/sync/planned_meal_sync_service.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

class PlannedMealSyncService implements SyncService {
  final FirebasePlannedMealRepositoryImpl firebaseRepo;
  final HivePlannedMealRepositoryImpl hiveRepo;
  final NetworkInfo networkInfo;
  final FirebaseAuth _auth;

  PlannedMealSyncService({
    required this.firebaseRepo,
    required this.hiveRepo,
    required this.networkInfo,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  Box<PlannedMealModel> get _box => Hive.box<PlannedMealModel>('plannedMeals');

  /// Klucz z namespacingiem po UID
  String _keyUid(DateTime date, String mealId) => '${_uid}_${date}_$mealId';

  /// Stary klucz (bez UID) – fallback do migracji
  String _keyLegacy(DateTime date, String mealId) => '${date}_$mealId';

  /// Pobierz model z Hive z uwzględnieniem migracji klucza
  PlannedMealModel? _getByAnyKey(DateTime date, String mealId) {
    final k1 = _keyUid(date, mealId);
    final byNew = _box.get(k1);
    if (byNew != null) return byNew;

    final k0 = _keyLegacy(date, mealId);
    return _box.get(k0);
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure());
    }

    debugLog('[SYNC] ▶️ start (uid=$_uid)', name: 'PM_SYNC');

    // === PUSH: wyślij lokalne niezsynchronizowane zmiany do Firestore ===
    final changesResult = await hiveRepo.getUnsyncedChangesForPlannedMeals();
    final push = await changesResult.fold<Future<Either<Failure, void>>>(
      (failure) async => Left(failure),
      (changes) async {
        debugLog('[SYNC][PUSH] unsynced changes: ${changes.length}', name: 'PM_SYNC');

        for (final entity in changes) {
          final model = _getByAnyKey(entity.date, entity.meal.mealId);
          if (model == null) {
            debugLog('[SYNC][PUSH] skip (not found in hive): ${entity.meal.mealId}', name: 'PM_SYNC');
            continue;
          }

          if (model.isDeleted) {
            final res = await firebaseRepo.removePlannedMeal(entity);
            if (res.isLeft()) return Left((res as Left).value);

            // usuń oba możliwe klucze
            await _box.delete(_keyUid(entity.date, entity.meal.mealId));
            await _box.delete(_keyLegacy(entity.date, entity.meal.mealId));
            debugLog('[SYNC][PUSH] removed remote & local: ${entity.meal.mealId}', name: 'PM_SYNC');
          } else {
            final res = await firebaseRepo.addPlannedMeal(entity);
            if (res.isLeft()) return Left((res as Left).value);

            // zapisz pod nowym kluczem z ownerUid
            await _box.put(
              _keyUid(entity.date, entity.meal.mealId),
              PlannedMealModel(
                date: entity.date,
                meal: MealMapper.toModel(entity.meal),
                isSynced: true,
                isDeleted: false,
                position: model.position,
                ownerUid: _uid,
              ),
            );
            // wyczyść ewentualny stary klucz
            await _box.delete(_keyLegacy(entity.date, entity.meal.mealId));
            debugLog('[SYNC][PUSH] upserted remote, updated hive (uid-key): ${entity.meal.mealId}', name: 'PM_SYNC');
          }
        }
        return const Right(null);
      },
    );

    if (push.isLeft()) return push;

    // === PULL: pobierz z Firestore -> zapisz do Hive (jako moje, ownerUid=_uid) ===
    final pullResult = await firebaseRepo.getPlannedMeals();
    return await pullResult.fold(
      (failure) async => Left(failure),
      (remoteEntities) async {
        debugLog('[SYNC][PULL] remote count: ${remoteEntities.length}', name: 'PM_SYNC');

        // Nie kasujemy niczego z Hive – jedynie uzupełniamy/uzgadniamy.
        for (final entity in remoteEntities) {
          await _upsertHiveFromRemote(entity);
        }

        debugLog('[SYNC] ✅ done', name: 'PM_SYNC');
        return const Right(null);
      },
    );
  }

  Future<void> _upsertHiveFromRemote(PlannedMealEntity entity) async {
    final key = _keyUid(entity.date, entity.meal.mealId);

    final current = _getByAnyKey(entity.date, entity.meal.mealId);
    final position = current?.position ?? entity.position;

    await _box.put(
      key,
      PlannedMealModel(
        date: entity.date,
        meal: MealMapper.toModel(entity.meal),
        position: position,
        isSynced: true,
        isDeleted: false,
        ownerUid: _uid, // 👈 WAŻNE: to moje rekordy w Hive
      ),
    );

    // Po migracji usuń legacy-klucz
    final legacyKey = _keyLegacy(entity.date, entity.meal.mealId);
    if (_box.containsKey(legacyKey)) {
      await _box.delete(legacyKey);
      debugLog('[SYNC][PULL] migrated legacy -> uid key: ${entity.meal.mealId}', name: 'PM_SYNC');
    }
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