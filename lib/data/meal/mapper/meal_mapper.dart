import 'package:mealapp/data/meal/models/meal.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

class MealMapper {
  static MealEntity toEntity(MealModel model) {
    return MealEntity(
      title: model.title,
      mealId: model.mealId,
      categoryId: model.categoryId,
      image: model.image,
      ingredients: model.ingredients,
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
      ingredients: entity.ingredients,
      steps: entity.steps,
      isVegetarian: entity.isVegetarian,
    );
  }
}
