// core/sync/shopping_list_meal_ingredient_sync_service.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/ingredient/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/remote/firebase_shopping_list_meal_ingredient_service.dart';

/// Synchronizacja listy zakupów z separacją danych per-user (ownerUid + key z uid).
class ShoppingListMealIngredientSyncService implements SyncService {
  final ShoppingListMealIngredientRepository _remoteRepo;
  final FirebaseShoppingListMealIngredientService _remoteService; // ⬅️ NOWE
  final NetworkInfo _networkInfo;
  final FirebaseAuth _auth;

  ShoppingListMealIngredientSyncService({
    required ShoppingListMealIngredientRepository remoteRepo,
    required FirebaseShoppingListMealIngredientService remoteService, // ⬅️ NOWE
    required NetworkInfo networkInfo,
    FirebaseAuth? auth,
  })  : _remoteRepo = remoteRepo,
        _remoteService = remoteService, // ⬅️ NOWE
        _networkInfo = networkInfo,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  Box<ShoppingListMealIngredientModel> get _box =>
      Hive.box<ShoppingListMealIngredientModel>('shoppingListMealIngredients');

  bool _isMine(ShoppingListMealIngredientModel m) =>
      m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  String _keyUid(ShoppingListMealIngredientModel m) =>
      '${_uid}_${m.meal.mealId}_${m.ingredient.ingredientId}';

  String _keyLegacy(ShoppingListMealIngredientModel m) =>
      '${m.meal.mealId}_${m.ingredient.ingredientId}';

  @override
  Future<Either<Failure, void>> syncData() async {
    if (!await _networkInfo.checkInternetConnection()) {
      return Left(NetworkFailure());
    }

    // === PUSH lokalnych zmian ===
    final unsyncedModels = _box.values.where((m) => !m.isSynced && _isMine(m));
    final deletedModels = unsyncedModels.where((m) => m.isDeleted).toList();
    final nonDeletedUnsyncedModels =
        _deduplicate(unsyncedModels.where((m) => !m.isDeleted));

    final deletionFailure = await _syncDeletedModels(deletedModels);
    if (deletionFailure != null) return Left(deletionFailure);

    final addFailure = await _syncAdditions(nonDeletedUnsyncedModels);
    if (addFailure != null) return Left(addFailure);

    // === PULL z Firestore -> upsert do Hive ===
    final pullFailure = await _pullFromRemote();
    if (pullFailure != null) return Left(pullFailure);

    return const Right(null);
  }

  List<ShoppingListMealIngredientModel> _deduplicate(
    Iterable<ShoppingListMealIngredientModel> models,
  ) {
    final map = <String, ShoppingListMealIngredientModel>{};
    for (final m in models) {
      map[_keyUid(m)] = m; // deduplikacja po kluczu z uid
    }
    return map.values.toList();
  }

  Future<Failure?> _syncDeletedModels(
    List<ShoppingListMealIngredientModel> models,
  ) async {
    for (final m in models) {
      final result = await _remoteRepo.removeMealIngredientFromShoppingList(
        MealMapper.toEntity(m.meal),
        IngredientMapper.toEntity(m.ingredient),
      );

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return failure;

      // usuń lokalnie: nowy i legacy klucz
      await _box.delete(_keyUid(m));
      await _box.delete(_keyLegacy(m));
    }
    return null;
  }

  Future<Failure?> _syncAdditions(
    List<ShoppingListMealIngredientModel> models,
  ) async {
    for (final m in models) {
      final addResult = await _remoteRepo.addMealIngredientToShoppingList(
        MealMapper.toEntity(m.meal),
        IngredientMapper.toEntity(m.ingredient),
        m.portionCount,
      );

      final failure = addResult.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return failure;

      // zapisz pod nowym kluczem i z ownerUid ustawionym na mnie
      final enriched =
          m.copyWith(isSynced: true, isDeleted: false, ownerUid: _uid);
      await _box.put(_keyUid(enriched), enriched);

      // usuń ewentualny legacy klucz
      await _box.delete(_keyLegacy(enriched));
    }
    return null;
  }

  /// ⬇️⬇️⬇️ NOWE: PULL z Firestore i zapis do Hive
  Future<Failure?> _pullFromRemote() async {
    try {
      final remoteModels =
          await _remoteService.getMealIngredientsFromShoppingList();

      for (final m in remoteModels.where((x) => !x.isDeleted)) {
        final enriched =
            m.copyWith(isSynced: true, isDeleted: false, ownerUid: _uid);
        await _box.put(_keyUid(enriched), enriched);

        // usuń ewentualny legacy klucz
        await _box.delete(_keyLegacy(enriched));
      }

      return null;
    } catch (_) {
      return NetworkFailure();
    }
  }
}