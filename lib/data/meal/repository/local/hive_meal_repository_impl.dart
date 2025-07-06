import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/source/local/hive_meal_service.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class HiveMealRepositoryImpl extends MealRepository {
  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(String categoryId) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final filteredMeals = meals.where((meal) => meal.categoryId.contains(categoryId)).toList();
      return filteredMeals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(String title) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final filteredMeals = meals.where((meal) => 
          meal.title.toLowerCase().contains(title.toLowerCase())).toList();
      return filteredMeals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(bool isVegetarian) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final filteredMeals = meals.where((meal) => meal.isVegetarian == isVegetarian).toList();
      return filteredMeals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(String categoryId) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final filteredMeals = meals.where((meal) => 
          meal.isVegetarian && meal.categoryId.contains(categoryId)).toList();
      return filteredMeals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(String title) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final filteredMeals = meals.where((meal) => 
          meal.isVegetarian && meal.title.toLowerCase().contains(title.toLowerCase())).toList();
      return filteredMeals.map(MealMapper.toEntity).toList();
    });
  }

  Future<void> saveMeals(List<MealEntity> meals) async {
    await sl<HiveMealService>().saveMeals(meals.map(MealMapper.toModel).toList());
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final allIngredients = <IngredientEntity>[];
      
      for (final meal in meals) {
        allIngredients.addAll(
          meal.ingredients.map((ingredient) => IngredientMapper.toEntity(ingredient))
        );
      }
      
      return allIngredients;
    });
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(String mealId) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final meal = meals.firstWhere((m) => m.mealId == mealId);
      return meal.ingredients.map(IngredientMapper.toEntity).toList();
    });
  }
}