import 'package:hive/hive.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class HivePlannedMealService {
  Future<List<PlannedMealModel>> getPlannedMeals();
  Future<void> savePlannedMeal(PlannedMealModel plannedMeal);
  Future<void> removePlannedMeal(DateTime date, String mealId);
}

class HivePlannedMealServiceImpl implements HivePlannedMealService {

  Box<PlannedMealModel> get _box => Hive.box<PlannedMealModel>('plannedMeals');

  @override
  Future<List<PlannedMealModel>> getPlannedMeals() async {
    return _box.values.toList();
  }

  @override
  Future<void> savePlannedMeal(PlannedMealModel plannedMeal) async {
    await _box.put(
        '${plannedMeal.date}_${plannedMeal.meal.mealId}', plannedMeal);
  }

  @override
  Future<void> removePlannedMeal(DateTime date, String mealId) async {
    await _box.delete('${date}_$mealId');
  }
}
