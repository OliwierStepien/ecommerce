import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/source/remote/firebase_meal_service.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class FirebaseMealRepositoryImpl implements MealRepository {
  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(
      String mealId) {
    return handleFirestoreFailure(() async {
      final ingredients = await sl<FirebaseMealService>().getIngredientsForMeal(mealId);
      return ingredients.map(IngredientMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() {
    return handleFirestoreFailure(() async {
      final ingredients = await sl<FirebaseMealService>().getAllIngredients();
      return ingredients.map(IngredientMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getMeals();
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getMealsByCategoryId(categoryId);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(
      String title) async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getMealsByTitle(title);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
Future<Either<Failure, bool>> addOrRemoveShoppingListIngredient(
    MealEntity meal, IngredientEntity ingredient, int portionCount) async {
  return handleFirestoreFailure(() async {
    return await sl<FirebaseMealService>().addOrRemoveShoppingListIngredient(
      MealMapper.toModel(meal),
      IngredientMapper.toModel(ingredient),
      portionCount,
    );
  });
}

  @override
  Future<Either<Failure, bool>> isIngredientInShoppingList(
      MealEntity meal) async {
    return handleFirestoreFailure(() async {
      return await sl<FirebaseMealService>()
          .isIngredientInShoppingList(MealMapper.toModel(meal));
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getShoppingList() async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getShoppingList();
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(
      bool isVegetarian) async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getMealsByIsVegetarian(isVegetarian);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getVegetarianMealsByCategoryId(categoryId);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(
      String title) async {
    return handleFirestoreFailure(() async {
      final meals = await sl<FirebaseMealService>().getVegetarianMealsByTitle(title);
      return meals.map(MealMapper.toEntity).toList();
    });
  }
}