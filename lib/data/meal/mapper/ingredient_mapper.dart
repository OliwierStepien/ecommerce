import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';

class IngredientMapper {
  static IngredientEntity toEntity(IngredientModel model) {
    return IngredientEntity(
      amountPerPortion: model.amountPerPortion,
      ingredientCategory: model.ingredientCategory,
      ingredientId: model.ingredientId,
      ingredientName: model.ingredientName,
      mealId: model.mealId,
      unit: model.unit,
    );
  }

  static IngredientModel toModel(IngredientEntity entity) {
    return IngredientModel(
      amountPerPortion: entity.amountPerPortion,
      ingredientCategory: entity.ingredientCategory,
      ingredientId: entity.ingredientId,
      ingredientName: entity.ingredientName,
      mealId: entity.mealId,
      unit: entity.unit,
    );
  }
}
