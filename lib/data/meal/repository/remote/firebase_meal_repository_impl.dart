import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/meal/source/remote/firebase_meal_service.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class FirebaseMealRepositoryImpl implements MealRepository {
  final FirebaseMealService _firebaseMealService;

  FirebaseMealRepositoryImpl({required FirebaseMealService firebaseMealService})
      : _firebaseMealService = firebaseMealService;

  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    return handleFirestoreFailure(() async {
      final meals = await _firebaseMealService.getMeals();
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final meals = await _firebaseMealService.getMealsByCategoryId(categoryId);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(
      String title) async {
    return handleFirestoreFailure(() async {
      final meals = await _firebaseMealService.getMealsByTitle(title);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(
      bool isVegetarian) async {
    return handleFirestoreFailure(() async {
      final meals =
          await _firebaseMealService.getMealsByIsVegetarian(isVegetarian);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreFailure(() async {
      final meals =
          await _firebaseMealService.getVegetarianMealsByCategoryId(categoryId);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(
      String title) async {
    return handleFirestoreFailure(() async {
      final meals = await _firebaseMealService.getVegetarianMealsByTitle(title);
      return meals.map(MealMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<MealEntity>>> saveMeals(
      List<MealEntity> meals) async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }
}
