import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/planned_meal/mapper/planned_meal_mapper.dart';
import 'package:mealapp/data/planned_meal/source/local/hive_planned_meal_service.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class HivePlannedMealRepositoryImpl implements PlannedMealRepository {
  final HivePlannedMealService _hivePlannedMealService;
  final NetworkInfo _networkInfo;

  HivePlannedMealRepositoryImpl({
    required HivePlannedMealService hivePlannedMealService,
    required NetworkInfo networkInfo,
  })  : _hivePlannedMealService = hivePlannedMealService,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> addPlannedMeal(
      PlannedMealEntity plannedMeal) async {
    return handleHiveFailure(() async {
      final model = PlannedMealMapper.toModel(plannedMeal);
      await _hivePlannedMealService.savePlannedMeal(model);
    });
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(
      DateTime date, String mealId) async {
    return handleHiveFailure(() async {
      final isOnline = await _networkInfo.checkInternetConnection();
      await _hivePlannedMealService.removePlannedMeal(date, mealId,
          isOnline: isOnline);
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return handleHiveFailure(() async {
      final models = await _hivePlannedMealService.getPlannedMeals();
      return models.map(PlannedMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>>
      getUnsyncedPlannedMeals() async {
    return handleHiveFailure(() async {
      final models = await _hivePlannedMealService.getUnsyncedPlannedMeals();
      return models.map(PlannedMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedChanges() async {
    return handleHiveFailure(() async {
      final models = await _hivePlannedMealService.getUnsyncedChanges();
      return models.map(PlannedMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
      DateTime date, String mealId) async {
    return handleHiveFailure(() async {
      await _hivePlannedMealService.markAsSynced(date, mealId);
    });
  }
}
