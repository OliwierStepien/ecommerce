import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class GetShoppingListUseCase
    implements UseCase<Either<Failure, List<MealEntity>>, void> {
  final ShoppingListMealIngredientRepository shoppingListMealIngredientRepository;

  GetShoppingListUseCase(this.shoppingListMealIngredientRepository);

  @override
  Future<Either<Failure, List<MealEntity>>> call({void params}) async {
    return await shoppingListMealIngredientRepository.getMealIngredientToShoppingList();
  }
}
