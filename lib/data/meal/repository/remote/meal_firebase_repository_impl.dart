import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/models/meal.dart';
import 'package:mealapp/data/meal/source/remote/meal_firebase_service.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class MealRepositoryImpl extends MealRepository {
  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<MealFirebaseService>().getMeals();
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
          await sl<MealFirebaseService>().getMealsByCategoryId(categoryId);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(String title) async {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<MealFirebaseService>().getMealsByTitle(title);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, bool>> addOrRemoveFavoriteMeal(MealEntity meal) async {
    return handleFirestoreFailure(() async {
      return await sl<MealFirebaseService>().addOrRemoveFavoriteMeal(meal);
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getFavoritesMeals() async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<MealFirebaseService>().getFavoritesMeals();
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, bool>> addOrRemoveShoppingListIngredient(
      MealEntity meal) async {
    return handleFirestoreFailure(() async {
      return await sl<MealFirebaseService>()
          .addOrRemoveShoppingListIngredient(meal);
    });
  }

  @override
  Future<Either<Failure, bool>> isIngredientInShoppingList(
      MealEntity meal) async {
    return handleFirestoreFailure(() async {
      return await sl<MealFirebaseService>().isIngredientInShoppingList(meal);
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getShoppingList() async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<MealFirebaseService>().getShoppingList();
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
          await sl<MealFirebaseService>().getMealsByIsVegetarian(isVegetarian);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final returnedData = await sl<MealFirebaseService>()
          .getVegetarianMealsByCategoryId(categoryId);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }
  
  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(String title) async {
    return handleFirestoreFailure(() async {
      final returnedData =
          await sl<MealFirebaseService>().getVegetarianMealsByTitle(title);
      return returnedData
          .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
          .toList();
    });
  }
}
