import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

abstract class PlannedMealRepository {
  Future<Either<Failure, void>> addPlannedMeal(PlannedMealEntity plannedMeal);
  Future<Either<Failure, void>> removePlannedMeal(DateTime date, String mealId);
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals();
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedPlannedMeals();
  Future<Either<Failure, void>> markPlannedMealAsSynced(DateTime date, String mealId);
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedChangesForPlannedMeals();
}