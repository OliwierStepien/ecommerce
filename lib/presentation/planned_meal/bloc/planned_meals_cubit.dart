import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/usecase/add_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/get_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meals_in_date_range_usecase.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_state.dart';
import 'package:table_calendar/table_calendar.dart';

class PlannedMealsCubit extends Cubit<PlannedMealsState> {
  final GetPlannedMealsUseCase getPlannedMeals;
  final AddPlannedMealUseCase addPlannedMealUseCase;
  final RemovePlannedMealUseCase removePlannedMealUseCase;
  final RemovePlannedMealsInDateRangeUseCase removeInRangeUseCase;

  DateTime _selectedDay;
  DateTime _focusedDay;
  Map<DateTime, List<PlannedMealEntity>> _groupedMeals = {};

  PlannedMealsCubit({
    required this.getPlannedMeals,
    required this.addPlannedMealUseCase,
    required this.removePlannedMealUseCase,
    required this.removeInRangeUseCase,
  })  : _selectedDay = normalizeDate(DateTime.now()),
        _focusedDay = normalizeDate(DateTime.now()),
        super(PlannedMealsInitial()) {
    loadPlannedMeals();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> loadPlannedMeals() async {
    emit(PlannedMealsLoading());
    final result = await getPlannedMeals.call(NoParams());

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
        const SnackBar(
          content: Text('This meal is already planned for that day.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final result = await addPlannedMealUseCase.call(plannedMeal);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mapFailureToMessage(failure)),
            duration: const Duration(seconds: 1),
          ),
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
          const SnackBar(
            content: Text('Meal added to plan'),
            duration: Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Future<bool> removePlannedMeal(PlannedMealEntity plannedMeal) async {
    final result = await removePlannedMealUseCase.call(plannedMeal);

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

  Future<void> removePlannedMealsInDateRange(
    DateTime start,
    DateTime end,
    void Function(String message) showMessage,
  ) async {
    emit(PlannedMealsLoading());

    final params = DateRangeParams(start: start, end: end);
    final result = await removeInRangeUseCase.call(params);

    result.fold(
      (failure) {
        showMessage(mapFailureToMessage(failure));
        emit(PlannedMealsError(mapFailureToMessage(failure)));
      },
      (_) {
        _groupedMeals.removeWhere(
            (date, _) => !date.isBefore(start) && !date.isAfter(end));

        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
        ));

        showMessage('Meals removed successfully in selected range');
      },
    );
  }
}
