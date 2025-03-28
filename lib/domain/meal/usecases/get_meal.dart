import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class GetMealUseCase
    implements UseCase<Either<Failure, List<MealEntity>>, bool> {
  @override
  Future<Either<Failure, List<MealEntity>>> call({bool? params}) async {
    if (params == true) {
      return await sl<MealRepository>().isMealVegetarian(true);
    } else {
      return await sl<MealRepository>().getMeals();
    }
  }
}