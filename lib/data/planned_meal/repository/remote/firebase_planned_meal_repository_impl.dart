import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/source/remote/firebase_planned_meal_service.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class FirebasePlannedMealRepositoryImpl implements PlannedMealRepository {
  @override
  Future<Either<Failure, void>> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    return handleFirestoreFailure(() async {
      await sl<FirebasePlannedMealService>().addPlannedMeal(plannedMeal);
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(DateTime date, String mealId) async {
    return handleFirestoreFailure(() async {
      await sl<FirebasePlannedMealService>().removePlannedMeal(date, mealId);
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return handleFirestoreFailure(() async {
      final data = await sl<FirebasePlannedMealService>().getPlannedMeals();
      return data.map((e) {
        final model = PlannedMealModel.fromMap(e);
        return PlannedMealEntity(
          date: model.date,
          meal: MealMapper.toEntity(model.meal),
        );
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedPlannedMeals() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedChanges() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> markAsSynced(DateTime date, String mealId) async {
    return const Right(null);
  }
}