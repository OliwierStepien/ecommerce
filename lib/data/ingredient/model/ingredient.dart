class IngredientModel {
  final num amountPerPortion;
  final String ingredientCategory;
  final String ingredientId;
  final String ingredientName;
  final String mealId;
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
