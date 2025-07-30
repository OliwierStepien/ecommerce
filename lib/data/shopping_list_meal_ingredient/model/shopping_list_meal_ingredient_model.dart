import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

part 'shopping_list_meal_ingredient_model.g.dart';

@HiveType(typeId: 7)
class ShoppingListMealIngredientModel {
  @HiveField(0)
  final MealModel meal;
  @HiveField(1)
  final IngredientModel ingredient;
  @HiveField(2)
  final int portionCount;
  @HiveField(3)
  final bool isSynced;
  @HiveField(4)
  final bool isDeleted;

  const ShoppingListMealIngredientModel({
    required this.meal,
    required this.ingredient,
    required this.portionCount,
    required this.isSynced,
    required this.isDeleted,
  });

  ShoppingListMealIngredientModel copyWith({
    MealModel? meal,
    IngredientModel? ingredient,
    int? portionCount,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return ShoppingListMealIngredientModel(
      meal: meal ?? this.meal,
      ingredient: ingredient ?? this.ingredient,
      portionCount: portionCount ?? this.portionCount,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    final scaledAmount = ingredient.amountPerPortion != null
        ? ingredient.amountPerPortion! * portionCount
        : null;
    return {
      'meal': meal.toMap(),
      'ingredient': ingredient.toMap(),
      'portionCount': portionCount,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'scaledAmount': scaledAmount,
    };
  }

  factory ShoppingListMealIngredientModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListMealIngredientModel(
      meal: MealModel.fromMap(map['meal']),
      ingredient: IngredientModel.fromMap(map['ingredient']),
      portionCount: map['portionCount'] ?? 1,
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
