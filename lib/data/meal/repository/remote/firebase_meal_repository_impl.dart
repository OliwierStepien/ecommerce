import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:mealapp/data/meal/source/remote/firebase_meal_service.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class FirebaseMealRepositoryImpl extends MealRepository {
  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(
      String mealId) {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<FirebaseMealService>().getIngredientsForMeal(mealId);
      return returnedData
          .map((e) => IngredientMapper.toEntity(IngredientModel.fromMap(e)))
          .toList();
    });
  }

  @override
Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() {
  return handleFirestoreFailure(() async {
    final returnedData = await sl<FirebaseMealService>().getAllIngredients();
    return returnedData
        .map((e) => IngredientMapper.toEntity(IngredientModel.fromMap(e)))
        .toList();
  });
}

  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<FirebaseMealService>().getMeals();
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<FirebaseMealService>().getMealsByCategoryId(categoryId);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(
      String title) async {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<FirebaseMealService>().getMealsByTitle(title);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, bool>> addOrRemoveShoppingListIngredient(
      MealEntity meal) async {
    return handleFirestoreFailure(() async {
      return await sl<FirebaseMealService>()
          .addOrRemoveShoppingListIngredient(meal);
    });
  }

  @override
  Future<Either<Failure, bool>> isIngredientInShoppingList(
      MealEntity meal) async {
    return handleFirestoreFailure(() async {
      return await sl<FirebaseMealService>().isIngredientInShoppingList(meal);
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getShoppingList() async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<FirebaseMealService>().getShoppingList();
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(
      bool isVegetarian) async {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<FirebaseMealService>().getMealsByIsVegetarian(isVegetarian);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<FirebaseMealService>()
          .getVegetarianMealsByCategoryId(categoryId);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(
      String title) async {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<FirebaseMealService>().getVegetarianMealsByTitle(title);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }
}
