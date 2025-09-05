import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

abstract class HiveMealService {
  Future<List<MealModel>> getMeals();
  Future<void> saveMeals(List<MealModel> meals);
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
}