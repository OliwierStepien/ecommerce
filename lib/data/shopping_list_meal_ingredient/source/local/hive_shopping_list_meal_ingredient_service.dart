import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';

abstract class HiveShoppingListMealIngredientService {
  Future<void> addMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount);
  Future<void> removeMealIngredientFromShoppingList(
      MealModel meal, IngredientModel ingredient,
      {bool isOnline = false});
  Future<List<ShoppingListMealIngredientModel>>
      getMealIngredientToShoppingList();
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedShoppingListMealIngredient();
  Future<void> markShoppingListMealIngredientAsSynced(
      String mealId, String ingredientId);
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedChangesForShoppingListMealIngredient();
  Future<void> restoreMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount);
  Future<void> clearSyncedDeletedItems();
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

    final allIngredients = await getMealIngredientToShoppingList();
    print(
        '✅ Dodano składnik: ${ingredient.ingredientName} (z posiłku: ${meal.title})');
    print('🛒 Liczba składników w shopping list: ${allIngredients.length}');
    print('📋 Składniki:');
    for (final item in allIngredients) {
      print(' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})');
    }
  }

  @override
  Future<void> removeMealIngredientFromShoppingList(
      MealModel meal, IngredientModel ingredient,
      {bool isOnline = false}) async {
    final key = '${meal.mealId}_${ingredient.ingredientId}';
    final model = _box.get(key);

    if (model != null) {
      await _box.put(
        key,
        ShoppingListMealIngredientModel(
          meal: model.meal,
          ingredient: model.ingredient,
          portionCount: model.portionCount,
          isSynced: isOnline,
          isDeleted: true,
        ),
      );
    }

    final allIngredients = await getMealIngredientToShoppingList();
    print(
        '❌ Usunięto składnik: ${ingredient.ingredientName} (z posiłku: ${meal.title})');
    print('🛒 Liczba składników w shopping list: ${allIngredients.length}');
    print('📋 Składniki:');
    for (final item in allIngredients) {
      print(' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})');
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
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedChangesForShoppingListMealIngredient() async {
    return _box.values.where((model) => !model.isSynced).toList();
  }

  @override
  Future<void> markShoppingListMealIngredientAsSynced(
      String mealId, String ingredientId) async {
    final key = '${mealId}_${ingredientId}';
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

      print('✅ Zaznaczono jako zsynchronizowany: ${ingredientId} (z posiłku: ${mealId})');
    }
  }

  @override
  Future<void> restoreMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount) async {
    final key = '${meal.mealId}_${ingredient.ingredientId}';
    final existingModel = _box.get(key);

    if (existingModel != null) {
      await _box.put(
        key,
        ShoppingListMealIngredientModel(
          meal: existingModel.meal,
          ingredient: existingModel.ingredient,
          portionCount: portionCount,
          isSynced: false,
          isDeleted: false,
        ),
      );
    } else {
      await _box.put(
        key,
        ShoppingListMealIngredientModel(
          meal: meal,
          ingredient: ingredient,
          portionCount: portionCount,
          isSynced: false,
          isDeleted: false,
        ),
      );
    }

    final allIngredients = await getMealIngredientToShoppingList();
    final allItemsInBox = _box.values.toList();

    print('♻️ Przywrócono składnik: ${ingredient.ingredientName} (z posiłku: ${meal.title})');
    print('🔑 Klucz: $key');
    print('📦 Ilość wpisów w Hive: ${allItemsInBox.length}');
    print('🛒 Liczba aktywnych składników w shopping list: ${allIngredients.length}');
    print('📋 Aktywne składniki:');
    for (final item in allIngredients) {
      print(' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})');
    }
    print('🗑️ Usunięte składniki:');
    for (final item in allItemsInBox.where((m) => m.isDeleted)) {
      print(' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})');
    }
  }

  @override
  Future<void> clearSyncedDeletedItems() async {
    final keysToDelete = _box.keys.where((key) {
      final item = _box.get(key);
      return item != null && item.isDeleted && item.isSynced;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
      print('🧹 Usunięto trwale zsynchronizowany składnik z kluczem: $key');
    }
  }
}