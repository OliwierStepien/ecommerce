import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

part 'favorite_meal_model.g.dart';

@HiveType(typeId: 6)
class FavoriteMealModel {
  @HiveField(0)
  final MealModel meal;
  @HiveField(1)
  final bool isSynced;
  @HiveField(2)
  final bool isDeleted;

  const FavoriteMealModel({
    required this.meal,
    required this.isSynced,
    required this.isDeleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'mealId': meal.mealId,
      'meal': meal.toMap(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory FavoriteMealModel.fromMap(Map<String, dynamic> map) {
    return FavoriteMealModel(
      meal: MealModel.fromMap(map['meal']),
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
