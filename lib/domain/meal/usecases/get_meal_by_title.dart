import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class GetMealByTitleUseCase
    implements
        UseCase<Either<Failure, List<MealEntity>>, Map<String, dynamic>> {
  @override
  Future<Either<Failure, List<MealEntity>>> call(
      {Map<String, dynamic>? params}) async {
    final title = params?['title'] as String;
    final isVegetarian = params?['isVegetarian'] as bool;

    if (isVegetarian) {
      return await sl<MealRepository>().getVegetarianMealsByTitle(title);
    } else {
      return await sl<MealRepository>().getMealsByTitle(title);
    }
  }
}
