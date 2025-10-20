import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/usecase/add_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/get_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meal_usecase.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_state.dart';
import 'package:mealapp/service_locator.dart';

class PlannedMealsCubit extends Cubit<PlannedMealsState> {
  DateTime _selectedDay;
  DateTime _focusedDay;
  Map<DateTime, List<PlannedMealEntity>> _groupedMeals = {};

  PlannedMealsCubit()
      : _selectedDay = DateTime.now(),
        _focusedDay = DateTime.now(),
        super(PlannedMealsInitial()) {
    _selectedDay = _normalizeDate(_selectedDay);
    _focusedDay = _normalizeDate(_focusedDay);
    loadPlannedMeals();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> loadPlannedMeals() async {
    emit(PlannedMealsLoading());
    final result = await sl<GetPlannedMealsUseCase>().call();

    result.fold(
      (failure) => emit(PlannedMealsError(mapFailureToMessage(failure))),
      (plannedMeals) {
        _groupedMeals = _groupByDate(plannedMeals);

        // 🛠️ Normalize selectedDay after load to ensure key match
        _selectedDay = _normalizeDate(_selectedDay);

        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
        ));
      },
    );
  }

  Map<DateTime, List<PlannedMealEntity>> _groupByDate(
      List<PlannedMealEntity> plannedMeals) {
    final Map<DateTime, List<PlannedMealEntity>> result = {};
    for (final plannedMeal in plannedMeals) {
      final date = _normalizeDate(plannedMeal.date);
      result[date] = [...result[date] ?? [], plannedMeal];
    }
    return result;
  }

  void changeDay(DateTime selected, DateTime focused) {
    _selectedDay = _normalizeDate(selected);
    _focusedDay = _normalizeDate(focused);
    if (state is PlannedMealsLoaded) {
      emit(PlannedMealsLoaded(
        plannedMeals: Map.from(_groupedMeals),
        selectedDay: _selectedDay,
        focusedDay: _focusedDay,
      ));
    }
  }

Future<void> addPlannedMeal(
    PlannedMealEntity plannedMeal, BuildContext context) async {
  final date = _normalizeDate(plannedMeal.date);
  final existingMeals = _groupedMeals[date] ?? [];

  // 🛑 Sprawdzenie duplikatu na podstawie mealId
  final alreadyAdded = existingMeals.any(
    (meal) => meal.meal.mealId == plannedMeal.meal.mealId,
  );

  if (alreadyAdded) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This meal is already planned for that day.')),
    );
    return;
  }

  final result = await sl<AddPlannedMealUseCase>().call(params: plannedMeal);

  result.fold(
    (failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFailureToMessage(failure))),
      );
    },
    (_) {
      _groupedMeals[date] = [...existingMeals, plannedMeal];

      emit(PlannedMealsLoaded(
        plannedMeals: Map.from(_groupedMeals),
        selectedDay: _selectedDay,
        focusedDay: _focusedDay,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal added to plan')),
      );
    },
  );
}

Future<bool> removePlannedMeal(PlannedMealEntity plannedMeal) async {
  final result = await sl<RemovePlannedMealUseCase>().call(params: plannedMeal);

  return result.fold(
    (failure) => false,
    (_) {
      final normalizedDate = _normalizeDate(plannedMeal.date);
      final mealId = plannedMeal.meal.mealId;

      if (_groupedMeals.containsKey(normalizedDate)) {
        _groupedMeals[normalizedDate] = _groupedMeals[normalizedDate]!
            .where((meal) => meal.meal.mealId != mealId)
            .toList();

        if (_groupedMeals[normalizedDate]!.isEmpty) {
          _groupedMeals.remove(normalizedDate);
        }
      }

      emit(PlannedMealsLoaded(
        plannedMeals: Map.from(_groupedMeals),
        selectedDay: _selectedDay,
        focusedDay: _focusedDay,
      ));

      return true;
    },
  );
}
}
