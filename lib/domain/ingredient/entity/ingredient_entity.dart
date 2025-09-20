import 'package:equatable/equatable.dart';

class IngredientEntity extends Equatable {
  final num? amountPerPortion;
  final String ingredientCategory;
  final String ingredientId;
  final String ingredientName;
  final String mealId;
  final String unit;

  const IngredientEntity({
    required this.amountPerPortion,
    required this.ingredientCategory,
    required this.ingredientId,
    required this.ingredientName,
    required this.mealId,
    required this.unit,
  });

  IngredientEntity copyWith({
    num? amountPerPortion,
    String? ingredientCategory,
    String? ingredientId,
    String? ingredientName,
    String? mealId,
    String? unit,
  }) {
    return IngredientEntity(
      amountPerPortion: amountPerPortion ?? this.amountPerPortion,
      ingredientCategory: ingredientCategory ?? this.ingredientCategory,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      mealId: mealId ?? this.mealId,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [
        amountPerPortion,
        ingredientCategory,
        ingredientId,
        ingredientName,
        mealId,
        unit,
      ];
}
