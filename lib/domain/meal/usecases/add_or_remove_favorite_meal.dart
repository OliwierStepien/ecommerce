import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class AddOrRemoveFavoriteMealUseCase implements UseCase<Either, MealEntity> {
  @override
  Future<Either> call({MealEntity? params}) async {
    return await sl<MealRepository>().addOrRemoveFavoriteMeal(params!);
  }
}
