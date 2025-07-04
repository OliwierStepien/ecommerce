import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class AddToShoppingListUseCase
    implements UseCase<void, Map<String, dynamic>> {
  final MealRepository mealRepository;

  AddToShoppingListUseCase(this.mealRepository);

  @override
  Future<void> call({Map<String, dynamic>? params}) async {
    final meal = params?['meal'] as MealEntity;
    final ingredient = params?['ingredient'] as IngredientEntity;
    final portionCount = params?['portionCount'] as int;
    
    await mealRepository.addToShoppingList(meal, ingredient, portionCount);
  }
}