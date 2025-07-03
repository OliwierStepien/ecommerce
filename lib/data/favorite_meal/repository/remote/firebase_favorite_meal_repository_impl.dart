import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/favorite_meal/mapper/favorite_meal_mapper.dart';
import 'package:mealapp/data/favorite_meal/source/remote/firebase_favorite_meal_service.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class FirebaseFavoriteMealRepositoryImpl implements FavoriteMealRepository {
  final FirebaseFavoriteMealService _firebaseFavoriteMealService;

  FirebaseFavoriteMealRepositoryImpl(
      {required FirebaseFavoriteMealService firebaseFavoriteMealService})
      : _firebaseFavoriteMealService = firebaseFavoriteMealService;

  @override
  Future<Either<Failure, void>> addFavoriteMeal(FavoriteMealEntity meal) async {
    return handleFirestoreFailure(() async {
      await _firebaseFavoriteMealService.addFavoriteMeal(
        FavoriteMealMapper.toModel(meal),
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeFavoriteMeal(String mealId) async {
    return handleFirestoreFailure(() async {
      await _firebaseFavoriteMealService.removeFavoriteMeal(mealId);
    });
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getFavoritesMeals() async {
    return handleFirestoreFailure(() async {
      final returnedData = await _firebaseFavoriteMealService.getFavoritesMeals();
      return returnedData.map(FavoriteMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedChangesForFavoriteMeals() async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedFavoriteMeals() async {
    return handleFirestoreFailure(() async {
      final allMeals = await _firebaseFavoriteMealService.getFavoritesMeals();
      return allMeals.map(FavoriteMealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markFavoriteMealAsSynced(String mealId) async {
    return handleFirestoreFailure(() async {
      return;
    });
  }
}