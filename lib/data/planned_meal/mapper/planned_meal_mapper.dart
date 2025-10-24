// data/planned_meal/mapper/planned_meal_mapper.dart
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

class PlannedMealMapper {
  static PlannedMealEntity toEntity(PlannedMealModel model) {
    return PlannedMealEntity(
      date: model.date,
      meal: MealMapper.toEntity(model.meal),
      position: model.position, // 👈 Mapowanie position
    );
  }

  static PlannedMealModel toModel(PlannedMealEntity entity) {
    return PlannedMealModel(
      date: entity.date,
      meal: MealMapper.toModel(entity.meal),
      position: entity.position, // 👈 Mapowanie position
      isSynced: false,
      isDeleted: false,
    );
  }
}