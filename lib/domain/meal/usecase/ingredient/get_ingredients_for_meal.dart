import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class GetIngredientsForMealUseCase
    implements
        UseCase<Either<Failure, List<IngredientEntity>>, Map<String, dynamic>> {
  final MealRepository mealRepository;

  GetIngredientsForMealUseCase(this.mealRepository);

  @override
  Future<Either<Failure, List<IngredientEntity>>> call(
      {Map<String, dynamic>? params}) async {
    return await mealRepository
        .getIngredientsForMeal(params!['mealId'] as String);
  }
}
