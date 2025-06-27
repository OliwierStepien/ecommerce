import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/source/local/hive_planned_meal_service.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class HivePlannedMealRepositoryImpl implements PlannedMealRepository {
  @override
  Future<Either<Failure, void>> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    return handleHiveFailure(() async {
      await sl<HivePlannedMealService>().savePlannedMeal(
        PlannedMealModel(
          date: plannedMeal.date,
          meal: MealMapper.toModel(plannedMeal.meal),
        ),
      );
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(DateTime date, String mealId) async {
    return handleHiveFailure(() async {
      await sl<HivePlannedMealService>().removePlannedMeal(date, mealId);
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return handleHiveFailure(() async {
      final meals = await sl<HivePlannedMealService>().getPlannedMeals();
      return meals.map((model) => PlannedMealEntity(
        date: model.date,
        meal: MealMapper.toEntity(model.meal),
      )).toList();
    });
  }
}