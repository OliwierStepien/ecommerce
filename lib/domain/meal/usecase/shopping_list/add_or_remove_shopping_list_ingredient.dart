import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class AddOrRemoveShoppingListIngredientUseCase
    implements UseCase<Either<Failure, bool>, Map<String, dynamic>> {
  final MealRepository mealRepository;

  AddOrRemoveShoppingListIngredientUseCase(this.mealRepository);

  @override
  Future<Either<Failure, bool>> call({Map<String, dynamic>? params}) async {
    final meal = params?['meal'] as MealEntity;
    final ingredient = params?['ingredient'] as IngredientEntity;
    final portionCount = params?['portionCount'] as int;
    
    return await mealRepository.addOrRemoveShoppingListIngredient(
      meal,
      ingredient,
      portionCount,
    );
  }
}