import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class GetMealUseCase
    implements UseCase<Either<Failure, List<MealEntity>>, bool> {
        final MealRepository mealRepository;

  GetMealUseCase(this.mealRepository);

  @override
  Future<Either<Failure, List<MealEntity>>> call(bool params) async {
    if (params) {
      return await mealRepository.isMealVegetarian(true);
    } else {
      return await mealRepository.getMeals();
    }
  }
}