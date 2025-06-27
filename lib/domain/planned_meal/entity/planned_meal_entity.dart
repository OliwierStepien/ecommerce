import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class PlannedMealEntity extends Equatable {
  final DateTime date;
  final MealEntity meal;
  
  const PlannedMealEntity({
    required this.date,
    required this.meal,
  });

  @override
  List<Object?> get props => [date, meal];
}