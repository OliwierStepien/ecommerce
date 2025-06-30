import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/core/network/network_info.dart';
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
          isSynced: false,
          isDeleted: false,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(DateTime date, String mealId) async {
    return handleHiveFailure(() async {
      final isOnline = await sl<NetworkInfo>().checkInternetConnection();
      final box = Hive.box<PlannedMealModel>('plannedMeals');
      final key = '${date}_$mealId';
      final model = box.get(key);

      if (model != null) {
        if (isOnline) {
          await box.delete(key);
        } else {
          await box.put(key, PlannedMealModel(
            date: model.date,
            meal: model.meal,
            isSynced: false,
            isDeleted: true,
          ));
        }
      }
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return handleHiveFailure(() async {
      final box = Hive.box<PlannedMealModel>('plannedMeals');
      final meals = box.values.where((model) => !model.isDeleted).toList();
      return meals.map((model) => PlannedMealEntity(
        date: model.date,
        meal: MealMapper.toEntity(model.meal),
      )).toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedPlannedMeals() async {
    return handleHiveFailure(() async {
      final box = Hive.box<PlannedMealModel>('plannedMeals');
      final unsynced = box.values.where((model) => !model.isSynced && !model.isDeleted).toList();
      return unsynced.map((model) => PlannedMealEntity(
        date: model.date,
        meal: MealMapper.toEntity(model.meal),
      )).toList();
    });
  }


  @override
  Future<Either<Failure, void>> markAsSynced(DateTime date, String mealId) async {
    return handleHiveFailure(() async {
      final box = Hive.box<PlannedMealModel>('plannedMeals');
      final key = '${date}_$mealId';
      final model = box.get(key);
      
      if (model != null && !model.isDeleted) {
        await box.put(key, PlannedMealModel(
          date: model.date,
          meal: model.meal,
          isSynced: true,
          isDeleted: false,
        ));
      }
    });
  }
  
  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedChanges() {
  return handleHiveFailure(() async {
    final box = Hive.box<PlannedMealModel>('plannedMeals');
    final unsynced = box.values.where((model) => !model.isSynced).toList();
    return unsynced.map((model) => PlannedMealEntity(
      date: model.date,
      meal: MealMapper.toEntity(model.meal),
    )).toList();
  });
}
}