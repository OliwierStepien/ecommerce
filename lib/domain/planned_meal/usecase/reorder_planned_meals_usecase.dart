// domain/planned_meal/usecase/reorder_planned_meals_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
    required DateTime date, // 👈 Potrzebujemy daty, bo grupowanie jest po dacie
  }) async {
    if (oldIndex == newIndex) {
      return Right(plannedMeals);
    }

    final updatedMeals = List<PlannedMealEntity>.from(plannedMeals);

    if (oldIndex < newIndex) newIndex -= 1;
    final movedMeal = updatedMeals.removeAt(oldIndex);

    if (newIndex > updatedMeals.length) newIndex = updatedMeals.length;
    if (newIndex < 0) newIndex = 0;

    updatedMeals.insert(newIndex, movedMeal);

    // Nadaj nowe pozycje
    for (int i = 0; i < updatedMeals.length; i++) {
      final updatedMeal = updatedMeals[i].copyWith(position: i);
      updatedMeals[i] = updatedMeal;
      
      // Zapisz zmiany w repozytorium
      final result = await repository.removePlannedMeal(updatedMeals[i]);
      result.fold(
        (failure) => debugPrint('❌ Nie udało się zaktualizować: ${updatedMeals[i].meal.title}'),
        (_) => debugPrint('✅ Zaktualizowano: ${updatedMeals[i].meal.title} (pos: ${updatedMeals[i].position})'),
      );
      
      // Dodaj z nową pozycją
      final addResult = await repository.addPlannedMeal(updatedMeal);
      addResult.fold(
        (failure) => debugPrint('❌ Nie udało się dodać: ${updatedMeal.meal.title}'),
        (_) => debugPrint('✅ Dodano: ${updatedMeal.meal.title} (pos: ${updatedMeal.position})'),
      );
    }

    return Right(updatedMeals);
  }
}