import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class ShoppingListMealIngredientEntity extends Equatable {
  final MealEntity meal;
  final IngredientEntity ingredient;
  final int portionCount;

  const ShoppingListMealIngredientEntity({
    required this.meal,
    required this.ingredient,
    required this.portionCount,
  });

  @override
  List<Object?> get props => [meal, ingredient, portionCount];
}