import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class PlannedMealRepositoryManager implements PlannedMealRepository {
  @override
  Future<Either<Failure, void>> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebasePlannedMealRepositoryImpl>().addPlannedMeal(plannedMeal);
      result.fold(
        (failure) => null,
        (_) async => await sl<HivePlannedMealRepositoryImpl>().addPlannedMeal(plannedMeal),
      );
      return result;
    } else {
      return await sl<HivePlannedMealRepositoryImpl>().addPlannedMeal(plannedMeal);
    }
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(DateTime date, String mealId) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebasePlannedMealRepositoryImpl>().removePlannedMeal(date, mealId);
      result.fold(
        (failure) => null,
        (_) async => await sl<HivePlannedMealRepositoryImpl>().removePlannedMeal(date, mealId),
      );
      return result;
    } else {
      return await sl<HivePlannedMealRepositoryImpl>().removePlannedMeal(date, mealId);
    }
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return await sl<HivePlannedMealRepositoryImpl>().getPlannedMeals();
  }
}