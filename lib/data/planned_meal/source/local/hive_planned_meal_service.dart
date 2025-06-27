import 'package:hive/hive.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class HivePlannedMealService {
  Future<List<PlannedMealModel>> getPlannedMeals();
  Future<void> savePlannedMeal(PlannedMealModel plannedMeal);
  Future<void> removePlannedMeal(DateTime date, String mealId);
}

class HivePlannedMealServiceImpl implements HivePlannedMealService {
  @override
  Future<List<PlannedMealModel>> getPlannedMeals() async {
    final box = Hive.box<PlannedMealModel>('plannedMeals');
    return box.values.toList();
  }

  @override
  Future<void> savePlannedMeal(PlannedMealModel plannedMeal) async {
    final box = Hive.box<PlannedMealModel>('plannedMeals');
    await box.put('${plannedMeal.date}_${plannedMeal.meal.mealId}', plannedMeal);
  }

  @override
  Future<void> removePlannedMeal(DateTime date, String mealId) async {
    final box = Hive.box<PlannedMealModel>('plannedMeals');
    await box.delete('${date}_$mealId');
  }
}