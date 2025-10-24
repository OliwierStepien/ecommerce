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
  Future<Either<Failure, void>> addPlannedMeal(
      PlannedMealEntity plannedMeal) async {
    // 1. Najpierw zawsze zapis lokalny
    final localResult = await _localRepository.addPlannedMeal(plannedMeal);
    if (localResult.isLeft()) return localResult;

    // 2. Synchronizacja jeśli online
    final isOnline = await _networkInfo.checkInternetConnection();
    if (!isOnline) return const Right(null);

    final remoteResult = await _remoteRepository.addPlannedMeal(plannedMeal);
    return remoteResult.fold(
      (failure) => const Right(null), // Nie oznaczaj sync przy błędzie
      (_) async {
        await _localRepository.markPlannedMealAsSynced(
            plannedMeal.date, plannedMeal.meal.mealId);
        return const Right(null);
      },
    );
  }

  @override
  Future<Either<Failure, void>> removePlannedMeal(
      PlannedMealEntity plannedMeal) async {
    // 1. Najpierw operacja lokalna
    final localResult = await _localRepository.removePlannedMeal(plannedMeal);
    if (localResult.isLeft()) return localResult;

    // 2. Synchronizacja jeśli online
    final isOnline = await _networkInfo.checkInternetConnection();
    if (!isOnline) return const Right(null);

    final remoteResult = await _remoteRepository.removePlannedMeal(plannedMeal);
    return remoteResult.fold(
      (failure) => const Right(null), // Zachowaj lokalne usunięcie
      (_) async {
        await _localRepository
            .removePlannedMeal(plannedMeal); // Pełne usunięcie
        return const Right(null);
      },
    );
  }

  @override
  Future<Either<Failure, void>> removePlannedMealsInDateRange(
      DateTime start, DateTime end) async {
    // 1. Najpierw usuń lokalnie
    final localResult =
        await _localRepository.removePlannedMealsInDateRange(start, end);
    if (localResult.isLeft()) return localResult;

    // 2. Jeśli jesteśmy offline — zakończ tutaj
    final isOnline = await _networkInfo.checkInternetConnection();
    if (!isOnline) return const Right(null);

    // 3. Usuń także zdalnie (Firebase)
    final remoteResult =
        await _remoteRepository.removePlannedMealsInDateRange(start, end);
    return remoteResult.fold(
      (failure) => const Right(null), // Lokalnie i tak już usunięto
      (_) async {
        // Po sukcesie można opcjonalnie zsynchronizować lokalny stan
        return const Right(null);
      },
    );
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> getPlannedMeals() async {
    return await _localRepository.getPlannedMeals();
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>>
      getUnsyncedPlannedMeals() async {
    return await _localRepository.getUnsyncedPlannedMeals();
  }

  @override
  Future<Either<Failure, void>> markPlannedMealAsSynced(
      DateTime date, String mealId) async {
    return await _localRepository.markPlannedMealAsSynced(date, mealId);
  }

  @override
  Future<Either<Failure, List<PlannedMealEntity>>>
      getUnsyncedChangesForPlannedMeals() async {
    return await _localRepository.getUnsyncedChangesForPlannedMeals();
  }

  @override
  Future<Either<Failure, void>> updatePlannedMeal(
      PlannedMealEntity plannedMeal) async {
    // 1. Najpierw zawsze zapis lokalny
    final localResult = await _localRepository.updatePlannedMeal(plannedMeal);
    if (localResult.isLeft()) return localResult;

    // 2. Synchronizacja jeśli online
    final isOnline = await _networkInfo.checkInternetConnection();
    if (!isOnline) return const Right(null);

    final remoteResult = await _remoteRepository.updatePlannedMeal(plannedMeal);
    return remoteResult.fold(
      (failure) => const Right(null), // Nie oznaczaj sync przy błędzie
      (_) async {
        await _localRepository.markPlannedMealAsSynced(
            plannedMeal.date, plannedMeal.meal.mealId);
        return const Right(null);
      },
    );
  }
}
