import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class RemoveFromShoppingListParams {
  final MealEntity meal;
  final IngredientEntity ingredient;
  const RemoveFromShoppingListParams({
    required this.meal,
    required this.ingredient,
  });
}

class RemoveFromShoppingListUseCase
    implements UseCase<void, RemoveFromShoppingListParams> {
  final ShoppingListMealIngredientRepository
      shoppingListMealIngredientRepository;

  RemoveFromShoppingListUseCase(this.shoppingListMealIngredientRepository);

  @override
  Future<void> call(RemoveFromShoppingListParams params) async {
    await shoppingListMealIngredientRepository
        .removeMealIngredientFromShoppingList(params.meal, params.ingredient);
  }
}
