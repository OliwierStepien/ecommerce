import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealapp/data/auth/model/user_model.dart';
import 'package:mealapp/data/category/model/category_model.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/shopping_list/model/shopping_list_item_model.dart';

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
    Hive.registerAdapter(ShoppingListItemModelAdapter());
    Hive.registerAdapter(PlannedMealModelAdapter());
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<UserModel>('users'),
      Hive.openBox<CategoryModel>('categories'),
      Hive.openBox<MealModel>('meals'),
      Hive.openBox<MealModel>('favoritesMeals'),
      Hive.openBox<MealModel>('shoppingList'),
      Hive.openBox<IngredientModel>('ingredients'),
      Hive.openBox<ShoppingListItemModel>('shoppingListItems'),
      Hive.openBox<PlannedMealModel>('plannedMeals'),
    ]);
  }

  // DODAJ TĘ NOWĄ METODĘ
  static Future<void> clearPlannedMealsBox() async {
    try {
      final box = Hive.box<PlannedMealModel>('plannedMeals');
      await box.clear();
      debugPrint('Successfully cleared plannedMeals box');
    } catch (e) {
      debugPrint('Error clearing plannedMeals box: $e');
      rethrow;
    }
  }

  static Future<void> close() async {
    await Hive.close();
  }
}