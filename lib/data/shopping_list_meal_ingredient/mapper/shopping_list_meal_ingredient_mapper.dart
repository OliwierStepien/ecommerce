import 'package:mealapp/data/ingredient/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class ShoppingListMealIngredientMapper {
  // Entity -> Model
  static ShoppingListMealIngredientModel toModel(
    MealEntity meal,
    IngredientEntity ingredient,
    int portionCount, {
    bool isChecked = false,
  }) {
    return ShoppingListMealIngredientModel(
      meal: MealMapper.toModel(meal),
      ingredient: IngredientMapper.toModel(ingredient),
      portionCount: portionCount,
      isSynced: false,
      isDeleted: false,
      isChecked: isChecked,
    );
  }

  // Model -> Entity
  static MapEntry<MealEntity, IngredientEntity> toEntity(
    ShoppingListMealIngredientModel model,
  ) {
    return MapEntry(
      MealMapper.toEntity(model.meal),
      IngredientMapper.toEntity(model.ingredient),
    );
  }
}
