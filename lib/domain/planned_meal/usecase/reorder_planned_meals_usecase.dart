// domain/planned_meal/usecase/reorder_planned_meals_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class ReorderPlannedMealsUseCase {
  final PlannedMealRepository repository;

  ReorderPlannedMealsUseCase(this.repository);

  Future<Either<Failure, List<PlannedMealEntity>>> call({
    required List<PlannedMealEntity> plannedMeals,
    required int oldIndex,
    required int newIndex,
    required DateTime date,
  }) async {
    if (oldIndex == newIndex) {
      return Right(plannedMeals);
    }

    final updatedMeals = List<PlannedMealEntity>.from(plannedMeals);

    // Dostosuj indeksy dla ReorderableListView
    if (oldIndex < newIndex) newIndex -= 1;
    final movedMeal = updatedMeals.removeAt(oldIndex);
    updatedMeals.insert(newIndex, movedMeal);

    // Aktualizuj pozycje
    for (int i = 0; i < updatedMeals.length; i++) {
      updatedMeals[i] = updatedMeals[i].copyWith(position: i);
    }

    // 👇 ZAPISZ TYLKO ZMIENIONE POZYCJE
    // Znajdź posiłki, których pozycja się zmieniła
    final mealsToUpdate = <PlannedMealEntity>[];
    for (int i = 0; i < updatedMeals.length; i++) {
      final originalMeal = plannedMeals.firstWhere(
        (meal) => meal.meal.mealId == updatedMeals[i].meal.mealId,
        orElse: () => updatedMeals[i],
      );
      
      if (originalMeal.position != updatedMeals[i].position) {
        mealsToUpdate.add(updatedMeals[i]);
      }
    }

    // Zapisz tylko zmienione pozycje
    for (final meal in mealsToUpdate) {
      final result = await repository.updatePlannedMeal(meal);
      if (result.isLeft()) {
        return Left((result as Left<Failure, void>).value);
      }
    }

    return Right(updatedMeals);
  }
}