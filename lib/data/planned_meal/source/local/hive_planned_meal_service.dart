import 'package:hive/hive.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class HivePlannedMealService {
  Future<List<PlannedMealModel>> getPlannedMeals();
  Future<List<PlannedMealModel>> getUnsyncedPlannedMeals();
  Future<List<PlannedMealModel>> getUnsyncedChanges();
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal);
  Future<void> markAsSynced(DateTime date, String mealId);
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal, {bool isOnline});
}

class HivePlannedMealServiceImpl implements HivePlannedMealService {
  Box<PlannedMealModel> get _box => Hive.box<PlannedMealModel>('plannedMeals');

  @override
  Future<List<PlannedMealModel>> getPlannedMeals() async {
    return _box.values.where((model) => !model.isDeleted).toList();
  }

  @override
  Future<List<PlannedMealModel>> getUnsyncedPlannedMeals() async {
    return _box.values
        .where((model) => !model.isSynced && !model.isDeleted)
        .toList();
  }

  @override
  Future<List<PlannedMealModel>> getUnsyncedChanges() async {
    return _box.values.where((model) => !model.isSynced).toList();
  }

  @override
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal) async {
    await _box.put(
        '${plannedMeal.date}_${plannedMeal.meal.mealId}', plannedMeal);
  }

  @override
  Future<void> markAsSynced(DateTime date, String mealId) async {
    final key = '${date}_$mealId';
    final model = _box.get(key);
    if (model != null && !model.isDeleted) {
      await _box.put(
          key,
          PlannedMealModel(
            date: model.date,
            meal: model.meal,
            isSynced: true,
            isDeleted: false,
          ));
    }
  }

  @override
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal,
      {bool isOnline = false}) async {
    final key = '${plannedMeal.date}_${plannedMeal.meal.mealId}';
    if (isOnline) {
      await _box.delete(key);
    } else {
      final model = _box.get(key);
      if (model != null) {
        await _box.put(
          key,
          model.copyWith(isDeleted: true, isSynced: false),
        );
      }
    }
  }
}
