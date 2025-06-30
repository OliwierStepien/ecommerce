import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/planned_meal/mapper/planned_meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/source/remote/firebase_planned_meal_service.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class FirebasePlannedMealRepositoryImpl implements PlannedMealRepository {
  final FirebasePlannedMealService _firebasePlannedMealService;

  FirebasePlannedMealRepositoryImpl({
    required FirebasePlannedMealService firebasePlannedMealService,
  }) : _firebasePlannedMealService = firebasePlannedMealService;

  @override
  Future<Either<Failure, void>> addPlannedMeal(
      PlannedMealEntity plannedMeal) async {
    return handleFirestoreFailure(() async {
      await _firebasePlannedMealService.addPlannedMeal(plannedMeal);
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(
      DateTime date, String mealId) async {
    return handleFirestoreFailure(() async {
      await _firebasePlannedMealService.removePlannedMeal(date, mealId);
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return handleFirestoreFailure(() async {
      final data = await _firebasePlannedMealService.getPlannedMeals();
      return data
          .map((e) => PlannedMealMapper.toEntity(PlannedMealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedPlannedMeals() async {
    return handleFirestoreFailure(() async {
      final allMeals = await _firebasePlannedMealService.getPlannedMeals();
      return allMeals
          .map((e) => PlannedMealMapper.toEntity(PlannedMealModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedChanges() async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
      DateTime date, String mealId) async {
    return handleFirestoreFailure(() async {
    });
  }
}