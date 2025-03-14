import 'package:dartz/dartz.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/models/meal.dart';
import 'package:mealapp/data/meal/source/product_firebase_service.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class MealRepositoryImpl extends MealRepository {
  @override
  Future<Either> getMeals() async {
    final returnedData = await sl<MealFirebaseService>().getMeals();
    return returnedData.fold((error) {
      return Left(error);
    }, (data) {
      return Right(
        List.from(data)
            .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
            .toList(),
      );
    });
  }

  @override
  Future<Either> getMealsByCategoryId(String categoryId) async {
    final returnedData =
        await sl<MealFirebaseService>().getMealsByCategoryId(categoryId);
    return returnedData.fold((error) {
      return Left(error);
    }, (data) {
      return Right(
        List.from(data)
            .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
            .toList(),
      );
    });
  }

  @override
  Future<Either> getMealsByTitle(String title) async {
    final returnedData = await sl<MealFirebaseService>().getMealsByTitle(title);
    return returnedData.fold((error) {
      return Left(error);
    }, (data) {
      return Right(
        List.from(data)
            .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
            .toList(),
      );
    });
  }

  @override
  Future<Either> addOrRemoveFavoriteMeal(MealEntity meal) async {
    final returnedData =
        await sl<MealFirebaseService>().addOrRemoveFavoriteMeal(meal);
    return returnedData.fold((error) {
      return Left(error);
    }, (data) {
      return Right(data);
    });
  }

  @override
  Future<bool> isFavorite(String mealId) async {
    return await sl<MealFirebaseService>().isFavorite(mealId);
  }

  @override
  Future<Either> getFavoritesMeals() async {
    final returnedData = await sl<MealFirebaseService>().getFavoritesMeals();
    return returnedData.fold((error) {
      return Left(error);
    }, (data) {
      return Right(
        List.from(data)
            .map((e) => MealMapper.toEntity(MealModel.fromMap(e)))
            .toList(),
      );
    });
  }
}
