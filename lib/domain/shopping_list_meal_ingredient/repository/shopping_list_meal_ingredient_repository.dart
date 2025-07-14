import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

abstract class ShoppingListMealIngredientRepository {
  Future<Either<Failure, void>> addMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount);
  Future<Either<Failure, void>> restoreMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount);
  Future<Either<Failure, void>> removeMealIngredientFromShoppingList(
      MealEntity meal, IngredientEntity ingredient);
  Future<Either<Failure, List<MealEntity>>> getMealIngredientToShoppingList();
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedShoppingListMealIngredient();
  Future<Either<Failure, void>> markShoppingListMealIngredientAsSynced(
      String mealId);
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedChangesForShoppingListMealIngredient();
}
