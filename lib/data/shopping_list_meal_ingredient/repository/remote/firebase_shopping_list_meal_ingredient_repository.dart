import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/ingredient/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/mapper/shopping_list_meal_ingredient_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/remote/firebase_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/entity/shopping_list_item_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class FirebaseShoppingListMealIngredientRepositoryImpl
    implements ShoppingListMealIngredientRepository {
  final FirebaseShoppingListMealIngredientService
      _firebaseShoppingListMealIngredientService;

  FirebaseShoppingListMealIngredientRepositoryImpl({
    required FirebaseShoppingListMealIngredientService
        firebaseShoppingListMealIngredientService,
  }) : _firebaseShoppingListMealIngredientService =
            firebaseShoppingListMealIngredientService;

  @override
  Future<Either<Failure, void>> addMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount) async {
    return handleFirestoreFailure(() async {
      final model = ShoppingListMealIngredientMapper.toModel(
          meal, ingredient, portionCount);
      await _firebaseShoppingListMealIngredientService
          .addMealIngredientToShoppingList(model);
    });
  }

  @override
  Future<Either<Failure, void>> removeMealIngredientFromShoppingList(
      MealEntity meal, IngredientEntity ingredient) async {
    return handleFirestoreFailure(() async {
      final model =
          ShoppingListMealIngredientMapper.toModel(meal, ingredient, 1);
      await _firebaseShoppingListMealIngredientService
          .removeMealIngredientFromShoppingList(model);
    });
  }

@override
Future<Either<Failure, List<ShoppingListItemEntity>>> getMealIngredientToShoppingList() async {
  return handleFirestoreFailure(() async {
    final models = await _firebaseShoppingListMealIngredientService
        .getMealIngredientsFromShoppingList();
    
    return models.map((model) => ShoppingListItemEntity(
      meal: MealMapper.toEntity(model.meal),
      ingredient: IngredientMapper.toEntity(model.ingredient),
      portionCount: model.portionCount,
    )).toList();
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
    return handleFirestoreFailure(() async {
      final allModels = await _firebaseShoppingListMealIngredientService
          .getMealIngredientsFromShoppingList();
      return allModels.map((model) => MealMapper.toEntity(model.meal)).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markShoppingListMealIngredientAsSynced(
      String mealId) async {
    return handleFirestoreFailure(() async {});
  }

  @override
  Future<Either<Failure, void>> restoreMealIngredientToShoppingList(
      MealEntity meal, IngredientEntity ingredient, int portionCount) async {
    return handleFirestoreFailure(() async {
      final model = ShoppingListMealIngredientMapper.toModel(
          meal, ingredient, portionCount);
      await _firebaseShoppingListMealIngredientService
          .restoreMealIngredientToShoppingList(model);
    });
  }
}
