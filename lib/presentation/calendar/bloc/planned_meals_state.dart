import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

abstract class PlannedMealsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlannedMealsInitial extends PlannedMealsState {}

class PlannedMealsLoaded extends PlannedMealsState {
  final Map<DateTime, List<MealEntity>> plannedMeals;
  final DateTime selectedDay;
  final DateTime focusedDay;

  PlannedMealsLoaded({
    required this.plannedMeals,
    required this.selectedDay,
    required this.focusedDay,
  });

  @override
  List<Object?> get props => [plannedMeals, selectedDay, focusedDay];
}

class PlannedMealsError extends PlannedMealsState {
  final String message;

  PlannedMealsError({required this.message});

  @override
  List<Object?> get props => [message];
}