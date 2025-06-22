import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class MealMapper {
  static MealEntity toEntity(MealModel model) {
    return MealEntity(
      title: model.title,
      mealId: model.mealId,
      categoryId: model.categoryId,
      image: model.image,
      ingredients: model.ingredients
        .map((ingredientModel) => IngredientMapper.toEntity(ingredientModel))
        .toList(),
      steps: model.steps,
      isVegetarian: model.isVegetarian,
    );
  }

  static MealModel toModel(MealEntity entity) {
    return MealModel(
      title: entity.title,
      mealId: entity.mealId,
      categoryId: entity.categoryId,
      image: entity.image,
      ingredients: entity.ingredients
        .map((ingredientEntity) => IngredientMapper.toModel(ingredientEntity))
        .toList(),
      steps: entity.steps,
      isVegetarian: entity.isVegetarian,
    );
  }
}
