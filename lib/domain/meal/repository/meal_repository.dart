import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

abstract class MealRepository {
  Future<Either<Failure, List<MealEntity>>> getMeals();
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(String categoryId);
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(String title);
  Future<Either<Failure, bool>> addOrRemoveFavoriteMeal(MealEntity meal);
  Future<Either<Failure, bool>> isFavorite(String mealId);
  Future<Either<Failure, List<MealEntity>>> getFavoritesMeals();
  Future<Either<Failure, bool>> addOrRemoveShoppingListIngredient(MealEntity meal);
  Future<Either<Failure, bool>> isIngredientInShoppingList(MealEntity meal);
  Future<Either<Failure, List<MealEntity>>> getShoppingList();
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(bool isVegetarian);
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(String categoryId);
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(String title);
}
