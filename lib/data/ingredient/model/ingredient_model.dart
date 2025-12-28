import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

part 'ingredient_model.g.dart';

@HiveType(typeId: HiveTypeIds.ingredient)
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

  IngredientModel({
    required this.amountPerPortion,
    required this.ingredientCategory,
    required this.ingredientId,
    required this.ingredientName,
    required this.mealId,
    required this.unit,
  });

  IngredientModel copyWith({
    num? amountPerPortion,
    String? ingredientCategory,
    String? ingredientId,
    String? ingredientName,
    String? mealId,
    String? unit,
  }) {
    return IngredientModel(
      amountPerPortion: amountPerPortion ?? this.amountPerPortion,
      ingredientCategory: ingredientCategory ?? this.ingredientCategory,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      mealId: mealId ?? this.mealId,
      unit: unit ?? this.unit,
    );
  }

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
      amountPerPortion: _parseNum(map['amountPerPortion']),
      ingredientCategory: map['ingredientCategory']?.toString() ?? '',
      ingredientId: map['ingredientId']?.toString() ?? '',
      ingredientName: map['ingredientName']?.toString() ?? '',
      mealId: map['mealId']?.toString() ?? '',
      unit: map['unit']?.toString() ?? '',
    );
  }

  static num? _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
