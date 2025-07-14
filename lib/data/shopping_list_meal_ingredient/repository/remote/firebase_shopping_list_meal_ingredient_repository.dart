import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/remote/firebase_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class FirebaseShoppingListMealIngredientRepositoryImpl
    implements ShoppingListMealIngredientRepository {
  final FirebaseShoppingListMealIngredientService
      _firebaseShoppingListMealIngredientService;

  FirebaseShoppingListMealIngredientRepositoryImpl(
      {required FirebaseShoppingListMealIngredientService
          firebaseShoppingListMealIngredientService})
      : _firebaseShoppingListMealIngredientService =
            firebaseShoppingListMealIngredientService;

  @override
  Future<Either<Failure, void>> addMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount) async {
    return handleFirestoreFailure(() async {
      await _firebaseShoppingListMealIngredientService
          .addMealIngredientToShoppingList(
        MealMapper.toModel(meal),
        IngredientMapper.toModel(ingredient),
        portionCount,
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeMealIngredientFromShoppingList(
      MealEntity meal, IngredientEntity ingredient) async {
    return handleFirestoreFailure(() async {
      await _firebaseShoppingListMealIngredientService
          .removeMealIngredientFromShoppingList(
        MealMapper.toModel(meal),
        IngredientMapper.toModel(ingredient),
      );
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>>
      getMealIngredientToShoppingList() async {
    return handleFirestoreFailure(() async {
      final meals = await _firebaseShoppingListMealIngredientService
          .getMealIngredientToShoppingList();
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedChangesForShoppingListMealIngredient() async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>>
      getUnsyncedShoppingListMealIngredient() async {
    final allMeals = await _firebaseShoppingListMealIngredientService
        .getMealIngredientToShoppingList();
    return handleFirestoreFailure(() async {
      return allMeals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markShoppingListMealIngredientAsSynced(
      String mealId) async {
    return handleFirestoreFailure(() async {
      return;
    });
  }

  @override
  Future<Either<Failure, void>> restoreMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount) async {
    return handleFirestoreFailure(() async {
      await _firebaseShoppingListMealIngredientService
          .restoreMealIngredientToShoppingList(
        MealMapper.toModel(meal),
        IngredientMapper.toModel(ingredient),
        portionCount,
      );
    });
  }
}
