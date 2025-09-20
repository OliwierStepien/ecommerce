import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/favorite_meal/mapper/favorite_meal_mapper.dart';
import 'package:mealapp/data/favorite_meal/source/local/hive_favorite_meal_service.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class HiveFavoriteMealRepositoryImpl implements FavoriteMealRepository {
  final HiveFavoriteMealService _hiveFavoriteMealService;

  HiveFavoriteMealRepositoryImpl({
    required HiveFavoriteMealService hiveFavoriteMealService,
  })  : _hiveFavoriteMealService = hiveFavoriteMealService;

  @override
  Future<Either<Failure, void>> addFavoriteMeal(FavoriteMealEntity meal) async {
    return handleHiveFailure(() async {
      await _hiveFavoriteMealService.addFavoriteMeal(
        FavoriteMealMapper.toModel(meal),
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeFavoriteMeal(String mealId) async {
    return handleHiveFailure(() async {
      await _hiveFavoriteMealService.removeFavoriteMeal(mealId);
    });
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getFavoritesMeals() async {
    return handleHiveFailure(() async {
      final models = await _hiveFavoriteMealService.getFavoriteMeals();
      return models.map(FavoriteMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedFavoriteMeals() async {
    return handleHiveFailure(() async {
      final models = await _hiveFavoriteMealService.getUnsyncedFavoriteMeals();
      return models.map(FavoriteMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markFavoriteMealAsSynced(String mealId) async {
    return handleHiveFailure(() async {
      await _hiveFavoriteMealService.markFavoriteMealAsSynced(mealId);
    });
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedChangesForFavoriteMeals() async {
    return handleHiveFailure(() async {
      final models = await _hiveFavoriteMealService.getUnsyncedChanges();
      return models.map(FavoriteMealMapper.toEntity).toList();
    });
  }
}