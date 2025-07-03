import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';

abstract class FavoriteMealRepository {
  Future<Either<Failure, bool>> addOrRemoveFavoriteMeal(FavoriteMealEntity meal);
  Future<Either<Failure, List<FavoriteMealEntity>>> getFavoritesMeals();
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedFavoriteMeals();
  Future<Either<Failure, void>> markFavoriteMealAsSynced(String mealId);
  Future<Either<Failure, List<FavoriteMealEntity>>> getUnsyncedChangesForFavoriteMeals();
}
