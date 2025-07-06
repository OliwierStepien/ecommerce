import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';

abstract class HiveShoppingListMealIngredientService {
  Future<void> addMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount);
  Future<void> removeMealIngredientFromShoppingList(
      MealModel meal, IngredientModel ingredient, {bool isOnline = false});
  Future<List<ShoppingListMealIngredientModel>> getMealIngredientToShoppingList();
  Future<List<ShoppingListMealIngredientModel>> getUnsyncedShoppingListMealIngredient();
  Future<void> markShoppingListMealIngredientAsSynced(String mealId, String ingredientId);
  Future<List<ShoppingListMealIngredientModel>> getUnsyncedChangesForShoppingListMealIngredient();
}

class HiveShoppingListMealIngredientServiceImpl
    implements HiveShoppingListMealIngredientService {
  Box<ShoppingListMealIngredientModel> get _box =>
      Hive.box<ShoppingListMealIngredientModel>('shoppingListMealIngredients');

  @override
  Future<void> addMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount) async {
    final key = '${meal.mealId}_${ingredient.ingredientId}';

    final model = _box.get(key);

    await _box.put(
      key,
      ShoppingListMealIngredientModel(
        meal: meal,
        ingredient: ingredient,
        portionCount: portionCount,
        isSynced: model?.isSynced ?? false,
        isDeleted: false,
      ),
    );
  }

  @override
  Future<void> removeMealIngredientFromShoppingList(
      MealModel meal, IngredientModel ingredient,
      {bool isOnline = false}) async {
    final key = '${meal.mealId}_${ingredient.ingredientId}';

    if (isOnline) {
      await _box.delete(key);
    } else {
      final model = _box.get(key);
      if (model != null) {
        await _box.put(
          key,
          ShoppingListMealIngredientModel(
            meal: model.meal,
            ingredient: model.ingredient,
            portionCount: model.portionCount,
            isSynced: false,
            isDeleted: true,
          ),
        );
      }
    }
  }

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getMealIngredientToShoppingList() async {
    return _box.values.where((model) => !model.isDeleted).toList();
  }

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedShoppingListMealIngredient() async {
    return _box.values
        .where((model) => !model.isSynced && !model.isDeleted)
        .toList();
  }

  @override
  Future<void> markShoppingListMealIngredientAsSynced(
      String mealId, String ingredientId) async {
    final key = '${mealId}_$ingredientId';
    final model = _box.get(key);

    if (model != null) {
      await _box.put(
        key,
        ShoppingListMealIngredientModel(
          meal: model.meal,
          ingredient: model.ingredient,
          portionCount: model.portionCount,
          isSynced: true,
          isDeleted: model.isDeleted,
        ),
      );
    }
  }

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedChangesForShoppingListMealIngredient() async {
    return _box.values.where((model) => !model.isSynced).toList();
  }
}