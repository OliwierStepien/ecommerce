import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/repository/local/hive_meal_repository_impl.dart';
import 'package:mealapp/data/meal/repository/remote/firebase_meal_repository_impl.dart';
import 'package:mealapp/data/meal/source/local/hive_meal_service.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class MealRepositoryManager extends MealRepository {
  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    debugPrint('[MealRepo] Connection status: ${isOnline ? 'ONLINE' : 'OFFLINE'}');

    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getMeals();
      
      result.fold(
        (failure) => debugPrint('[MealRepo] Firebase error: $failure'),
        (meals) async {
          debugPrint('[MealRepo] Saving ${meals.length} meals to Hive');
          await sl<HiveMealRepositoryImpl>().saveMeals(meals);
        },
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getMeals();
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(String categoryId) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getMealsByCategoryId(categoryId);
      
      result.fold(
        (failure) => debugPrint('[MealRepo] Firebase error: $failure'),
        (meals) async {
          // Save all meals to Hive for offline access
          final allMealsResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
          allMealsResult.fold(
            (failure) => debugPrint('[MealRepo] Failed to save meals for offline: $failure'),
            (allMeals) async => await sl<HiveMealRepositoryImpl>().saveMeals(allMeals),
          );
        },
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getMealsByCategoryId(categoryId);
    }
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getAllIngredients();
      
      // Zapisz posiłki do Hive dla offline (ingredients są częścią meal)
      final mealsResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
      mealsResult.fold(
        (failure) => debugPrint('Failed to save meals for offline: $failure'),
        (meals) async => await sl<HiveMealRepositoryImpl>().saveMeals(meals),
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getAllIngredients();
    }
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(String mealId) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getIngredientsForMeal(mealId);
      
      // Zapisz posiłek do Hive dla offline
      final mealResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
      mealResult.fold(
        (failure) => debugPrint('Failed to save meal for offline: $failure'),
        (meals) async {
          final meal = meals.firstWhere((m) => m.mealId == mealId);
          await sl<HiveMealService>().saveMeals([MealMapper.toModel(meal)]);
        },
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getIngredientsForMeal(mealId);
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(String title) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getMealsByTitle(title);
      
      // Zapisz wszystkie posiłki do Hive dla offline
      final allMealsResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
      allMealsResult.fold(
        (failure) => debugPrint('Failed to save meals for offline: $failure'),
        (meals) async => await sl<HiveMealRepositoryImpl>().saveMeals(meals),
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getMealsByTitle(title);
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(String categoryId) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getVegetarianMealsByCategoryId(categoryId);
      
      // Zapisz wszystkie posiłki do Hive dla offline
      final allMealsResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
      allMealsResult.fold(
        (failure) => debugPrint('Failed to save meals for offline: $failure'),
        (meals) async => await sl<HiveMealRepositoryImpl>().saveMeals(meals),
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getVegetarianMealsByCategoryId(categoryId);
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(String title) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().getVegetarianMealsByTitle(title);
      
      // Zapisz wszystkie posiłki do Hive dla offline
      final allMealsResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
      allMealsResult.fold(
        (failure) => debugPrint('Failed to save meals for offline: $failure'),
        (meals) async => await sl<HiveMealRepositoryImpl>().saveMeals(meals),
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().getVegetarianMealsByTitle(title);
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(bool isVegetarian) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseMealRepositoryImpl>().isMealVegetarian(isVegetarian);
      
      // Zapisz wszystkie posiłki do Hive dla offline
      final allMealsResult = await sl<FirebaseMealRepositoryImpl>().getMeals();
      allMealsResult.fold(
        (failure) => debugPrint('Failed to save meals for offline: $failure'),
        (meals) async => await sl<HiveMealRepositoryImpl>().saveMeals(meals),
      );
      
      return result;
    } else {
      return await sl<HiveMealRepositoryImpl>().isMealVegetarian(isVegetarian);
    }
  }
}