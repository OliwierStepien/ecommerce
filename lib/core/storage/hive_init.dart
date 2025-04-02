import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealapp/data/auth/models/user.dart';
import 'package:mealapp/data/category/models/category.dart';
import 'package:mealapp/data/meal/models/meal.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(MealModelAdapter());
    
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<CategoryModel>('categories');
    await Hive.openBox<MealModel>('meals');
    await Hive.openBox<MealModel>('favorites');
    await Hive.openBox<MealModel>('shoppingList');
  }

  static Future<void> close() async {
    await Hive.close();
  }
}