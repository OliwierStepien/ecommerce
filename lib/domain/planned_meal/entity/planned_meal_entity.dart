// domain/planned_meal/entity/planned_meal_entity.dart
import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class PlannedMealEntity extends Equatable {
  final DateTime date;
  final MealEntity meal;
  final int position; // 👈 Dodajemy pole position
  
  const PlannedMealEntity({
    required this.date,
    required this.meal,
    required this.position, // 👈 Wymagane w konstruktorze
  });

  PlannedMealEntity copyWith({
    DateTime? date,
    MealEntity? meal,
    int? position, // 👈 Dodajemy copyWith dla position
  }) {
    return PlannedMealEntity(
      date: date ?? this.date,
      meal: meal ?? this.meal,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [date, meal, position];
}