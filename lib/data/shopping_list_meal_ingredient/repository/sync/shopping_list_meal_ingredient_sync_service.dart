import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/network/sync_service.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

/// Synchronizuje pozycje listy zakupów pomiędzy Hive a Firestore.
/// 1. Obsługa braku sieci
/// 2. Usuwa zdalnie elementy oznaczone _isDeleted_
/// 3. Dodaje/aktualizuje pozostałe elementy
/// 4. Zaznacza je jako zsynchronizowane w Hive
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
    // 1) sprawdź dostęp do sieci
    if (!await _networkInfo.checkInternetConnection()) {
      return Left(NetworkFailure());
    }

    final box = Hive.box<ShoppingListMealIngredientModel>(
        'shoppingListMealIngredients');
    final unsynced = box.values.where((m) => !m.isSynced);

    final deletions = unsynced.where((m) => m.isDeleted).toList();
    final additions = _deduplicate(unsynced.where((m) => !m.isDeleted));

    // 2) najpierw usuń elementy oznaczone jako usunięte
    final deletionFailure = await _syncDeletions(deletions, box);
    if (deletionFailure != null) return Left(deletionFailure);

    // 3) następnie dodaj / zaktualizuj resztę
    final addFailure = await _syncAdditions(additions, box);
    if (addFailure != null) return Left(addFailure);

    return const Right(null);
  }

  /* ---------- PRYWATNE METODY POMOCNICZE ---------- */

  /// Klucz `<mealId>_<ingredientId>` używany zarówno w Hive, jak i w Firestore
  String _modelKey(ShoppingListMealIngredientModel m) =>
      '${m.meal.mealId}_${m.ingredient.ingredientId}';

  /// Wybiera ostatnią wersję każdej pary `[mealId, ingredientId]`
  List<ShoppingListMealIngredientModel> _deduplicate(
    Iterable<ShoppingListMealIngredientModel> models,
  ) {
    final map = <String, ShoppingListMealIngredientModel>{};
    for (final m in models) {
      map[_modelKey(m)] = m; // nadpisuje starsze wpisy
    }
    return map.values.toList();
  }

  Future<Failure?> _syncDeletions(
    List<ShoppingListMealIngredientModel> models,
    Box<ShoppingListMealIngredientModel> box,
  ) async {
    for (final m in models) {
      final result = await _remoteRepo.removeMealIngredientFromShoppingList(
        MealMapper.toEntity(m.meal),
        IngredientMapper.toEntity(m.ingredient),
      );

      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      await box.delete(_modelKey(m));
    }
    return null;
  }

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

      final failure = _failureOrNull(addResult);
      if (failure != null) return failure;

      await box.put(
        _modelKey(m),
        m.copyWith(isSynced: true, isDeleted: false),
      );
    }
    return null;
  }

  /// Zwraca `Failure` jeśli lewa strona, w pp. `null`
  Failure? _failureOrNull(Either<Failure, void> result) =>
      result.fold((f) => f, (_) => null);
}
