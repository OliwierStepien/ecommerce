
import 'package:mealapp/data/favorite_meal/model/favorite_meal_model.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';

class FavoriteMealMapper {
  static FavoriteMealEntity toEntity(FavoriteMealModel model) {
    return FavoriteMealEntity(
      meal: MealMapper.toEntity(model.meal),
    );
  }

  static FavoriteMealModel toModel(FavoriteMealEntity entity) {
    return FavoriteMealModel(
      meal: MealMapper.toModel(entity.meal),
      isSynced: false,
      isDeleted: false,
    );
  }
}