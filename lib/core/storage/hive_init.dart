import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealapp/data/auth/model/user_model.dart';
import 'package:mealapp/data/category/model/category_model.dart';
import 'package:mealapp/data/favorite_meal/model/favorite_meal_model.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();

    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(MealModelAdapter());
    Hive.registerAdapter(IngredientModelAdapter());
    Hive.registerAdapter(PlannedMealModelAdapter());
    Hive.registerAdapter(FavoriteMealModelAdapter());
    Hive.registerAdapter(ShoppingListMealIngredientModelAdapter());
    Hive.registerAdapter(ShoppingListCustomItemModelAdapter());
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<UserModel>('users'),
      Hive.openBox<CategoryModel>('categories'),
      Hive.openBox<MealModel>('meals'),
      Hive.openBox<IngredientModel>('ingredients'),
      Hive.openBox<PlannedMealModel>('plannedMeals'),
      Hive.openBox<FavoriteMealModel>('favoritesMeals'),
      Hive.openBox<ShoppingListMealIngredientModel>(
          'shoppingListMealIngredients'),
      Hive.openBox<ShoppingListCustomItemModel>('shoppingListCustomItems'),
    ]);
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
