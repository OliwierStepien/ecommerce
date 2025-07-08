import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class RemovePlannedMealUseCase implements UseCase<Either<Failure, void>, RemovePlannedMealParams> {
  final PlannedMealRepository repository;

  RemovePlannedMealUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({RemovePlannedMealParams? params}) async {
    return await repository.removePlannedMeal(params!.date, params.mealId);
  }
}

class RemovePlannedMealParams {
  final DateTime date;
  final String mealId;

  RemovePlannedMealParams({required this.date, required this.mealId});
}