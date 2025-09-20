import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

abstract class HiveMealService {
  Future<List<MealModel>> getMeals();
  Future<void> saveMeals(List<MealModel> meals);
}

class HiveMealServiceImpl implements HiveMealService {
  Box<MealModel> get _box => Hive.box<MealModel>('meals');


  @override
  Future<List<MealModel>> getMeals() async {
    return _box.values.toList();
  }

  @override
  Future<void> saveMeals(List<MealModel> meals) async {
    await _box.clear();
    await _box.addAll(meals);
  }
}