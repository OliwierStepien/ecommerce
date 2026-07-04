import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class UpdateShoppingListCheckedStateParams {
  final MealEntity meal;
  final IngredientEntity ingredient;
  final bool isChecked;

  const UpdateShoppingListCheckedStateParams({
    required this.meal,
    required this.ingredient,
    required this.isChecked,
  });
}

class UpdateShoppingListCheckedStateUseCase
    implements
        UseCase<Either<Failure, void>, UpdateShoppingListCheckedStateParams> {
  final ShoppingListMealIngredientRepository
      shoppingListMealIngredientRepository;

  UpdateShoppingListCheckedStateUseCase(
      this.shoppingListMealIngredientRepository);

  @override
  Future<Either<Failure, void>> call(
      UpdateShoppingListCheckedStateParams params) async {
    return await shoppingListMealIngredientRepository
        .updateMealIngredientCheckedState(
      params.meal,
      params.ingredient,
      isChecked: params.isChecked,
    );
  }
}
