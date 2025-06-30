import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class PlannedMealRepositoryManager implements PlannedMealRepository {
  final PlannedMealRepository _localRepository;
  final PlannedMealRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  PlannedMealRepositoryManager({
    required PlannedMealRepository localRepository,
    required PlannedMealRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    final isOnline = await _networkInfo.checkInternetConnection();
    
    // Najpierw zawsze zapisujemy lokalnie
    final localResult = await _localRepository.addPlannedMeal(plannedMeal);
    
    if (localResult.isLeft()) {
      return localResult;
    }

    if (isOnline) {
      final remoteResult = await _remoteRepository.addPlannedMeal(plannedMeal);
      return remoteResult.fold(
        (failure) async {
          // Oznacz jako niezsynchronizowane jeśli błąd
          await _localRepository.markAsSynced(plannedMeal.date, plannedMeal.meal.mealId);
          return const Right(null);
        },
        (_) async {
          // Oznacz jako zsynchronizowane jeśli sukces
          await _localRepository.markAsSynced(plannedMeal.date, plannedMeal.meal.mealId);
          return const Right(null);
        },
      );
    }
    
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(DateTime date, String mealId) async {
    final isOnline = await _networkInfo.checkInternetConnection();
    
    // Najpierw zawsze oznaczamy jako usunięte lokalnie
    final localResult = await _localRepository.removePlannedMeal(date, mealId);
    
    if (localResult.isLeft()) {
      return localResult;
    }

    if (isOnline) {
      final remoteResult = await _remoteRepository.removePlannedMeal(date, mealId);
      return remoteResult.fold(
        (failure) => const Right(null), // Nadal zachowujemy lokalne usunięcie
        (_) async {
          // Jeśli sukces, możemy usunąć całkowicie z lokalnej bazy
          await _localRepository.removePlannedMeal(date, mealId);
          return const Right(null);
        },
      );
    }
    
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return await _localRepository.getPlannedMeals();
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedPlannedMeals() async {
    return await _localRepository.getUnsyncedPlannedMeals();
  }

  @override
  Future<Either<Failure, void>> markAsSynced(DateTime date, String mealId) async {
    return await _localRepository.markAsSynced(date, mealId);
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getUnsyncedChanges() async {
    return await _localRepository.getUnsyncedChanges();
  }
}