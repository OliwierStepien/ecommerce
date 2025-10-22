import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class RestoreToShoppingListParams {
  final MealEntity meal;
  final IngredientEntity ingredient;
  final int portionCount;
  const RestoreToShoppingListParams(
      {required this.meal,
      required this.ingredient,
      required this.portionCount});
}

class RestoreToShoppingListUseCase
    implements UseCase<void, RestoreToShoppingListParams> {
  final ShoppingListMealIngredientRepository
      shoppingListMealIngredientRepository;

  RestoreToShoppingListUseCase(this.shoppingListMealIngredientRepository);

  @override
  Future<void> call(RestoreToShoppingListParams params) async {
    await shoppingListMealIngredientRepository
        .restoreMealIngredientToShoppingList(
            params.meal, params.ingredient, params.portionCount);
  }
}
