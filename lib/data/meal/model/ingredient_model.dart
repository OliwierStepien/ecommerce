import 'package:hive/hive.dart';

part 'ingredient_model.g.dart';

@HiveType(typeId: 3)
class IngredientModel {
  @HiveField(0)
  final num? amountPerPortion;

  @HiveField(1)
  final String ingredientCategory;

  @HiveField(2)
  final String ingredientId;

  @HiveField(3)
  final String ingredientName;

  @HiveField(4)
  final String mealId;

  @HiveField(5)
  final String unit;

  IngredientModel(
      {required this.amountPerPortion,
      required this.ingredientCategory,
      required this.ingredientId,
      required this.ingredientName,
      required this.mealId,
      required this.unit});

  Map<String, dynamic> toMap() {
    return {
      'amountPerPortion': amountPerPortion,
      'ingredientCategory': ingredientCategory,
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'mealId': mealId,
      'unit': unit,
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      amountPerPortion: map['amountPerPortion'] as num,
      ingredientCategory: map['ingredientCategory'] as String,
      ingredientId: map['ingredientId'] as String,
      ingredientName: map['ingredientName'] as String,
      mealId: map['mealId'] as String,
      unit: map['unit'] as String,
    );
  }
}
