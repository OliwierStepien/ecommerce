import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

class AddPlannedMealUseCase
    implements UseCase<Either<Failure, void>, PlannedMealEntity> {
  final PlannedMealRepository repository;

  AddPlannedMealUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PlannedMealEntity params) async {
    return await repository.addPlannedMeal(params);
  }
}
