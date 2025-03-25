import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class GetFavoritesMealUseCase implements UseCase<Either<Failure, List<MealEntity>>, void> {
  @override
  Future<Either<Failure, List<MealEntity>>> call({void params}) async {
    return await sl<MealRepository>().getFavoritesMeals();
  }
}
