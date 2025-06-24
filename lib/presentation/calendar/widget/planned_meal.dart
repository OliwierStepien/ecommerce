import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class PlannedMeal {
  final DateTime date;
  final MealEntity meal;

  PlannedMeal({required this.date, required this.meal});
}