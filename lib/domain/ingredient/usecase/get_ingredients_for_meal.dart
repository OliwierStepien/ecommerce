import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';

class GetIngredientsForMealParams {
  final String mealId;
  const GetIngredientsForMealParams({required this.mealId});
}

class GetIngredientsForMealUseCase
    implements
        UseCase<Either<Failure, List<IngredientEntity>>,
            GetIngredientsForMealParams> {
  final IngredientRepository repository;

  GetIngredientsForMealUseCase(this.repository);

  @override
  Future<Either<Failure, List<IngredientEntity>>> call(
      GetIngredientsForMealParams params) async {
    return await repository.getIngredientsForMeal(params.mealId);
  }
}