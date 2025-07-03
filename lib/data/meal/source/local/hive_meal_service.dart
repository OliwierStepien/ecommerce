import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

abstract class HiveMealService {
  Future<List<MealModel>> getMeals();
  Future<void> saveMeals(List<MealModel> meals);
  
  Future<List<MealModel>> getShoppingList();
  Future<void> addToShoppingList(MealModel meal);
  Future<void> removeFromShoppingList(String mealId);
}

class HiveMealServiceImpl implements HiveMealService {
  @override
  Future<List<MealModel>> getMeals() async {
    final box = Hive.box<MealModel>('meals');
    return box.values.toList();
  }

  @override
  Future<void> saveMeals(List<MealModel> meals) async {
    final box = Hive.box<MealModel>('meals');
    await box.clear();
    await box.addAll(meals);
  }

  @override
  Future<List<MealModel>> getShoppingList() async {
    final box = Hive.box<MealModel>('shoppingList');
    return box.values.toList();
  }

  @override
  Future<void> addToShoppingList(MealModel meal) async {
    final box = Hive.box<MealModel>('shoppingList');
    await box.put(meal.mealId, meal);
  }

  @override
  Future<void> removeFromShoppingList(String mealId) async {
    final box = Hive.box<MealModel>('shoppingList');
    await box.delete(mealId);
  }
}