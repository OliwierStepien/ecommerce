import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealapp/data/auth/model/user_model.dart';
import 'package:mealapp/data/category/model/category_model.dart';
import 'package:mealapp/data/ingredient/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(MealModelAdapter());
    Hive.registerAdapter(IngredientModelAdapter());
    
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<CategoryModel>('categories');
    await Hive.openBox<MealModel>('meals');
    await Hive.openBox<MealModel>('favorites');
    await Hive.openBox<MealModel>('shoppingList');
    await Hive.openBox<IngredientModel>('ingredients');
  }

  static Future<void> close() async {
    await Hive.close();
  }
}