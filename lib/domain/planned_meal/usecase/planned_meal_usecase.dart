import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class AddPlannedMealUseCase implements UseCase<Either<Failure, void>, PlannedMealEntity> {
  final PlannedMealRepository repository;

  AddPlannedMealUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({PlannedMealEntity? params}) async {
    return await repository.addPlannedMeal(params!);
  }
}

class RemovePlannedMealUseCase implements UseCase<Either<Failure, void>, RemovePlannedMealParams> {
  final PlannedMealRepository repository;

  RemovePlannedMealUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({RemovePlannedMealParams? params}) async {
    return await repository.removePlannedMeal(params!.date, params.mealId);
  }
}

class GetPlannedMealsUseCase implements UseCase<Either<Failure, List<PlannedMealEntity>>, void> {
  final PlannedMealRepository repository;

  GetPlannedMealsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> call({void params}) async {
    return await repository.getPlannedMeals();
  }
}

class RemovePlannedMealParams {
  final DateTime date;
  final String mealId;

  RemovePlannedMealParams({required this.date, required this.mealId});
}