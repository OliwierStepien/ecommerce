import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class AddToShoppingListUseCase
    implements UseCase<void, Map<String, dynamic>> {
  final ShoppingListMealIngredientRepository shoppingListMealIngredientRepository;

  AddToShoppingListUseCase(this.shoppingListMealIngredientRepository);

  @override
  Future<void> call({Map<String, dynamic>? params}) async {
    final meal = params?['meal'] as MealEntity;
    final ingredient = params?['ingredient'] as IngredientEntity;
    final portionCount = params?['portionCount'] as int;
    
    await shoppingListMealIngredientRepository.addMealIngredientToShoppingList(meal, ingredient, portionCount);
  }
}