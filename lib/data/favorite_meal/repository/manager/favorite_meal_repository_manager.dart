import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class FavoriteMealRepositoryManager implements FavoriteMealRepository {
  final FavoriteMealRepository _localRepository;
  final FavoriteMealRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  FavoriteMealRepositoryManager({
    required FavoriteMealRepository localRepository,
    required FavoriteMealRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> addFavoriteMeal(FavoriteMealEntity meal) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository.addFavoriteMeal(meal);
    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remoteRepository.addFavoriteMeal(meal);
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository.markFavoriteMealAsSynced(meal.meal.mealId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> removeFavoriteMeal(String mealId) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository.removeFavoriteMeal(mealId);
    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remoteRepository.removeFavoriteMeal(mealId);
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository.markFavoriteMealAsSynced(mealId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getFavoritesMeals() async {
    return await _localRepository.getFavoritesMeals();
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedFavoriteMeals() async {
    return await _localRepository.getUnsyncedFavoriteMeals();
  }

  @override
  Future<Either<Failure, void>> markFavoriteMealAsSynced(String mealId) async {
    return await _localRepository.markFavoriteMealAsSynced(mealId);
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedChangesForFavoriteMeals() async {
    return await _localRepository.getUnsyncedChangesForFavoriteMeals();
  }
}