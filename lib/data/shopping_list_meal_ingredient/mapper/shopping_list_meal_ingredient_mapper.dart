
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/entity/shopping_list_meal_ingredient_entity.dart';

class ShoppingListMealIngredientMapper {
  static ShoppingListMealIngredientEntity toEntity(ShoppingListMealIngredientModel model) {
    return ShoppingListMealIngredientEntity(
      meal: MealMapper.toEntity(model.meal),
      ingredient: IngredientMapper.toEntity(model.ingredient),
      portionCount: model.portionCount,
    );
  }

  static ShoppingListMealIngredientModel toModel(
    ShoppingListMealIngredientEntity entity, {
    bool isSynced = false,
    bool isDeleted = false,
  }) {
    return ShoppingListMealIngredientModel(
      meal: MealMapper.toModel(entity.meal),
      ingredient: IngredientMapper.toModel(entity.ingredient),
      portionCount: entity.portionCount,
      isSynced: isSynced,
      isDeleted: isDeleted,
    );
  }
}