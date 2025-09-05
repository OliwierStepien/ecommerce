import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/entity/shopping_list_item_entity.dart';

abstract class ShoppingListMealIngredientRepository {
  Future<Either<Failure, void>> addMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount);
  Future<Either<Failure, void>> restoreMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount);
  Future<Either<Failure, void>> removeMealIngredientFromShoppingList(
      MealEntity meal, IngredientEntity ingredient);
    Future<Either<Failure, List<ShoppingListItemEntity>>> getMealIngredientToShoppingList();
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedShoppingListMealIngredient();
  Future<Either<Failure, void>> markShoppingListMealIngredientAsSynced(
      String mealId);
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedChangesForShoppingListMealIngredient();
}