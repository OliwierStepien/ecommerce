import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

abstract class PlannedMealsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlannedMealsInitial extends PlannedMealsState {}

class PlannedMealsLoading extends PlannedMealsState {}

class PlannedMealsLoaded extends PlannedMealsState {
  final Map<DateTime, List<PlannedMealEntity>> plannedMeals;
  final DateTime selectedDay;
  final DateTime focusedDay;

  /// Opcjonalna, jednorazowa wiadomość do pokazania w UI (SnackBar wg SnackBarTheme).
  final String? toastMessage;

  PlannedMealsLoaded({
    required this.plannedMeals,
    required this.selectedDay,
    required this.focusedDay,
    this.toastMessage,
  });

  PlannedMealsLoaded copyWith({
    Map<DateTime, List<PlannedMealEntity>>? plannedMeals,
    DateTime? selectedDay,
    DateTime? focusedDay,
    String? toastMessage,
  }) {
    return PlannedMealsLoaded(
      plannedMeals: plannedMeals ?? this.plannedMeals,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [plannedMeals, selectedDay, focusedDay, toastMessage];
}

class PlannedMealsError extends PlannedMealsState {
  final String message;

  PlannedMealsError(this.message);

  @override
  List<Object?> get props => [message];
}