import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'planned_meals_state.dart';

class PlannedMealsCubit extends Cubit<PlannedMealsState> {
  PlannedMealsCubit() : super(PlannedMealsInitial()) {
    final now = DateTime.now();
    _selectedDay = _normalizeDate(now);
    _focusedDay = _normalizeDate(now);
    emit(PlannedMealsLoaded(
      plannedMeals: _meals,
      selectedDay: _selectedDay,
      focusedDay: _focusedDay,
    ));
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
  
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<MealEntity>> _meals = {};

  void changeDay(DateTime selected, DateTime focused) {
    _selectedDay = _normalizeDate(selected);
    _focusedDay = _normalizeDate(focused);
    emit(PlannedMealsLoaded(
      plannedMeals: _meals,
      selectedDay: _selectedDay,
      focusedDay: _focusedDay,
    ));
  }

  void addMeal(DateTime day, MealEntity meal) {
    final meals = [...(_meals[day] ?? <MealEntity>[])];
    meals.add(meal);
    _meals = {..._meals, day: meals};
    emit(PlannedMealsLoaded(
      plannedMeals: _meals,
      selectedDay: _selectedDay,
      focusedDay: _focusedDay,
    ));
  }

  void removeMeal(DateTime day, MealEntity meal) {
    final meals = [...(_meals[day] ?? <MealEntity>[])];
    meals.remove(meal);
    if (meals.isEmpty) {
      final newMap = Map.of(_meals)..remove(day);
      _meals = newMap;
    } else {
      _meals = {..._meals, day: meals};
    }
    emit(PlannedMealsLoaded(
      plannedMeals: _meals,
      selectedDay: _selectedDay,
      focusedDay: _focusedDay,
    ));
  }
}