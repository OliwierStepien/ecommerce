import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';

abstract class IngredientRepository {
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(
      String mealId);
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients();
}