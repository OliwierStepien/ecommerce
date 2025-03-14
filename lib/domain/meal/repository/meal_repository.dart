import 'package:dartz/dartz.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

abstract class MealRepository {
  Future<Either> getMeals();
  Future<Either> getMealsByCategoryId(String categoryId);
  Future<Either> getMealsByTitle(String title);
  Future<Either> addOrRemoveFavoriteMeal(MealEntity meal);
  Future<bool> isFavorite(String mealId);
  Future<Either> getFavoritesMeals();
}
