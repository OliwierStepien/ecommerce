import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class GetPlannedMealsUseCase
    implements UseCase<Either<Failure, List<PlannedMealEntity>>, NoParams> {
  final PlannedMealRepository repository;

  GetPlannedMealsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlannedMealEntity>>> call(NoParams params) async {
    return await repository.getPlannedMeals();
  }
}
