import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/entity/shopping_list_item_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class ShoppingListMealIngredientRepositoryManager
    implements ShoppingListMealIngredientRepository {
  final ShoppingListMealIngredientRepository _localRepository;
  final ShoppingListMealIngredientRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  ShoppingListMealIngredientRepositoryManager({
    required ShoppingListMealIngredientRepository localRepository,
    required ShoppingListMealIngredientRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> addMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository.addMealIngredientToShoppingList(
        meal, ingredient, portionCount);

    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remoteRepository
            .addMealIngredientToShoppingList(meal, ingredient, portionCount);

        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository
                .markShoppingListMealIngredientAsSynced(meal.mealId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> removeMealIngredientFromShoppingList(
      MealEntity meal, IngredientEntity ingredient) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository
        .removeMealIngredientFromShoppingList(meal, ingredient);

    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remoteRepository
            .removeMealIngredientFromShoppingList(meal, ingredient);

        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository
                .markShoppingListMealIngredientAsSynced(meal.mealId);
            return const Right(null);
          },
        );
      },
    );
  }

@override
Future<Either<Failure, List<ShoppingListItemEntity>>> getMealIngredientToShoppingList() async {
  return await _localRepository.getMealIngredientToShoppingList();
}

  @override
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedShoppingListMealIngredient() async {
    return await _localRepository.getUnsyncedShoppingListMealIngredient();
  }

  @override
  Future<Either<Failure, void>> markShoppingListMealIngredientAsSynced(
      String mealId) async {
    return await _localRepository
        .markShoppingListMealIngredientAsSynced(mealId);
  }

  @override
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedChangesForShoppingListMealIngredient() async {
    return await _localRepository
        .getUnsyncedChangesForShoppingListMealIngredient();
  }

  @override
  Future<Either<Failure, void>> restoreMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository
        .restoreMealIngredientToShoppingList(meal, ingredient, portionCount);

    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult =
            await _remoteRepository.restoreMealIngredientToShoppingList(
                meal, ingredient, portionCount);

        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository
                .markShoppingListMealIngredientAsSynced(meal.mealId);
            return const Right(null);
          },
        );
      },
    );
  }
}
