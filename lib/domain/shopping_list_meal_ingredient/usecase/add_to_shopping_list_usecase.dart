import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class AddToShoppingListParams {
  final MealEntity meal;
  final IngredientEntity ingredient;
  final int portionCount;
  const AddToShoppingListParams(
      {required this.meal,
      required this.ingredient,
      required this.portionCount});
}

class AddToShoppingListUseCase
    implements UseCase<void, AddToShoppingListParams> {
  final ShoppingListMealIngredientRepository
      shoppingListMealIngredientRepository;

  AddToShoppingListUseCase(this.shoppingListMealIngredientRepository);

  @override
  Future<void> call(AddToShoppingListParams params) async {
    await shoppingListMealIngredientRepository.addMealIngredientToShoppingList(
        params.meal, params.ingredient, params.portionCount);
  }
}
