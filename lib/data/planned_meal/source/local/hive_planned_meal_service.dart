// data/planned_meal/source/local/hive_planned_meal_service.dart
import 'package:hive/hive.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class HivePlannedMealService {
  Future<List<PlannedMealModel>> getPlannedMeals();
  Future<List<PlannedMealModel>> getUnsyncedPlannedMeals();
  Future<List<PlannedMealModel>> getUnsyncedChanges();
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal);
  Future<void> markAsSynced(DateTime date, String mealId);
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal, {bool isOnline});
  Future<void> removePlannedMealsInDateRange(DateTime start, DateTime end,
      {bool isOnline});
  Future<void> updatePlannedMeal(PlannedMealModel plannedMeal);
}

class HivePlannedMealServiceImpl implements HivePlannedMealService {
  Box<PlannedMealModel> get _box => Hive.box<PlannedMealModel>('plannedMeals');

  @override
  Future<List<PlannedMealModel>> getPlannedMeals() async {
    final meals = _box.values.where((model) => !model.isDeleted).toList();
    // 👇 Sortowanie według pozycji
    meals.sort((a, b) => a.position.compareTo(b.position));
    return meals;
  }

  @override
  Future<List<PlannedMealModel>> getUnsyncedPlannedMeals() async {
    final meals = _box.values
        .where((model) => !model.isSynced && !model.isDeleted)
        .toList();
    // 👇 Sortowanie według pozycji
    meals.sort((a, b) => a.position.compareTo(b.position));
    return meals;
  }

  @override
  Future<List<PlannedMealModel>> getUnsyncedChanges() async {
    final meals = _box.values.where((model) => !model.isSynced).toList();
    // 👇 Sortowanie według pozycji
    meals.sort((a, b) => a.position.compareTo(b.position));
    return meals;
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
            position: model.position, // 👈 Zachowaj pozycję
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
          model.copyWith(
            isDeleted: true,
            isSynced: false,
            position: model.position, // 👈 Zachowaj pozycję
          ),
        );
      }
    }
  }

  @override
  Future<void> removePlannedMealsInDateRange(DateTime start, DateTime end,
      {bool isOnline = false}) async {
    // Pobieramy wszystkie posiłki
    final allMeals = _box.values.toList();

    // Filtrowanie tylko tych z wybranego zakresu
    final mealsInRange = allMeals.where((meal) {
      final date = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));
    });

    for (final meal in mealsInRange) {
      await removePlannedMeal(meal, isOnline: isOnline);
    }
  }

  @override
  Future<void> updatePlannedMeal(PlannedMealModel plannedMeal) async {
    await _box.put(
        '${plannedMeal.date}_${plannedMeal.meal.mealId}', plannedMeal);
  }
}
