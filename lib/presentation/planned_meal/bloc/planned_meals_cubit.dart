import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/usecase/add_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/get_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meals_in_date_range_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/reorder_planned_meals_usecase.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_state.dart';

class PlannedMealsCubit extends Cubit<PlannedMealsState> {
  final GetPlannedMealsUseCase getPlannedMeals;
  final AddPlannedMealUseCase addPlannedMealUseCase;
  final RemovePlannedMealUseCase removePlannedMealUseCase;
  final RemovePlannedMealsInDateRangeUseCase removeInRangeUseCase;
  final ReorderPlannedMealsUseCase reorderPlannedMealsUseCase;

  DateTime _selectedDay;
  DateTime _focusedDay;
  Map<DateTime, List<PlannedMealEntity>> _groupedMeals = {};

  PlannedMealsCubit({
    required this.getPlannedMeals,
    required this.addPlannedMealUseCase,
    required this.removePlannedMealUseCase,
    required this.removeInRangeUseCase,
    required this.reorderPlannedMealsUseCase,
  })  : _selectedDay = normalizeDate(DateTime.now()),
        _focusedDay = normalizeDate(DateTime.now()),
        super(PlannedMealsInitial()) {
    loadPlannedMeals();
  }

  static DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _normalizeDate(DateTime date) => normalizeDate(date);

  Future<void> loadPlannedMeals() async {
    emit(PlannedMealsLoading());
    final result = await getPlannedMeals.call(NoParams());

    result.fold(
      (failure) => emit(PlannedMealsError(mapFailureToMessage(failure))),
      (plannedMeals) {
        _groupedMeals = _groupByDate(plannedMeals);
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
    List<PlannedMealEntity> plannedMeals,
  ) {
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

  /// Dodaje plan bez odwołań do BuildContext/UI.
  /// Zamiast SnackBarów emituje `toastMessage`; UI pokaże je wg SnackBarTheme.
  Future<bool> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    final date = _normalizeDate(plannedMeal.date);
    final existingMeals = _groupedMeals[date] ?? [];

    // duplikat w danym dniu
    final alreadyAdded = existingMeals
        .any((meal) => meal.meal.mealId == plannedMeal.meal.mealId);

    if (alreadyAdded) {
      emit(PlannedMealsLoaded(
        plannedMeals: Map.from(_groupedMeals),
        selectedDay: _selectedDay,
        focusedDay: _focusedDay,
        toastMessage: 'Ten posiłek już został dodany tego dnia.',
      ));
      return false;
    }

    final result = await addPlannedMealUseCase.call(plannedMeal);

    return result.fold(
      (failure) {
        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: mapFailureToMessage(failure),
        ));
        return false;
      },
      (_) {
        _groupedMeals[date] = [...existingMeals, plannedMeal];
        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: 'Posiłek został dodany.',
        ));
        return true;
      },
    );
  }

  Future<bool> removePlannedMeal(PlannedMealEntity plannedMeal) async {
    final result = await removePlannedMealUseCase.call(plannedMeal);

    return result.fold(
      (failure) {
        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: mapFailureToMessage(failure),
        ));
        return false;
      },
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
          toastMessage: 'Posiłek został usunięty.',
        ));

        return true;
      },
    );
  }

  Future<void> removePlannedMealsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final params = DateRangeParams(start: start, end: end);
    final result = await removeInRangeUseCase.call(params);

    result.fold(
      (failure) {
        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: mapFailureToMessage(failure),
        ));
      },
      (_) {
        _groupedMeals.removeWhere(
          (date, _) => !date.isBefore(start) && !date.isAfter(end),
        );

        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: 'Posiłki w wybranym zakresie zostały usunięte.',
        ));
      },
    );
  }

  Future<void> reorderPlannedMeals({
    required int oldIndex,
    required int newIndex,
    required DateTime date,
  }) async {
    final normalizedDate = _normalizeDate(date);
    final currentMeals = _groupedMeals[normalizedDate] ?? [];

    if (currentMeals.isEmpty) return;

    final result = await reorderPlannedMealsUseCase.call(
      plannedMeals: currentMeals,
      oldIndex: oldIndex,
      newIndex: newIndex,
      date: normalizedDate,
    );

    result.fold(
      (failure) {
        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: mapFailureToMessage(failure),
        ));
      },
      (updatedMeals) {
        _groupedMeals[normalizedDate] = updatedMeals;
        emit(PlannedMealsLoaded(
          plannedMeals: Map.from(_groupedMeals),
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          toastMessage: 'Kolejność posiłków została zmieniona.',
        ));
      },
    );
  }
}
