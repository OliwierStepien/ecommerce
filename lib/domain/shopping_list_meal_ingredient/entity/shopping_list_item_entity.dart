// shopping_list_item_entity.dart
import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class ShoppingListItemEntity extends Equatable {
  final MealEntity meal;
  final IngredientEntity ingredient;
  final int portionCount;
  final bool isChecked;

  const ShoppingListItemEntity({
    required this.meal,
    required this.ingredient,
    required this.portionCount,
    this.isChecked = false,
  });

  @override
  List<Object?> get props => [meal, ingredient, portionCount, isChecked];
}