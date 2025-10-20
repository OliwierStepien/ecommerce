import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/planned_meal/mapper/planned_meal_mapper.dart';
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
      // Konwersja Entity na Model przed wysłaniem do Firebase
      final model = PlannedMealMapper.toModel(plannedMeal);
      await _firebasePlannedMealService.addPlannedMeal(model);
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(
      PlannedMealEntity plannedMeal) async {
    return handleFirestoreFailure(() async {
      final model = PlannedMealMapper.toModel(plannedMeal);
      await _firebasePlannedMealService.removePlannedMeal(model);
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return handleFirestoreFailure(() async {
      final models = await _firebasePlannedMealService.getPlannedMeals();
      return models.map(PlannedMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>>
      getUnsyncedPlannedMeals() async {
    return handleFirestoreFailure(() async {
      // W Firebase wszystkie dane są traktowane jako zsynchronizowane
      final allMeals = await _firebasePlannedMealService.getPlannedMeals();
      return allMeals.map(PlannedMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>>
      getUnsyncedChangesForPlannedMeals() async {
    return handleFirestoreFailure(() async {
      // Firebase nie przechowuje niezsynchronizowanych zmian
      return [];
    });
  }

  @override
  Future<Either<Failure, void>> markPlannedMealAsSynced(
      DateTime date, String mealId) async {
    return handleFirestoreFailure(() async {
      // W Firebase nie ma potrzeby oznaczania jako zsynchronizowane
      return;
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMealsInDateRange(
      DateTime start, DateTime end) async {
    return handleFirestoreFailure(() async {
      await _firebasePlannedMealService.removePlannedMealsInDateRange(
          start, end);
    });
  }
}
