
import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

part 'shopping_list_item_model.g.dart';

@HiveType(typeId: 4)
class ShoppingListItemModel {
  @HiveField(0)
  final String ingredientId;
  
  @HiveField(1)
  final String ingredientName;
  
  @HiveField(2)
  final double? amountPerPortion;
  
  @HiveField(3)
  final double? scaledAmount;
  
  @HiveField(4)
  final String unit;
  
  @HiveField(5)
  final String ingredientCategory;
  
  @HiveField(6)
  final String? mealId;
  
  @HiveField(7)
  final String? title;
  
  @HiveField(8)
  final MealModel? meal;

  ShoppingListItemModel({
    required this.ingredientId,
    required this.ingredientName,
    this.amountPerPortion,
    this.scaledAmount,
    required this.unit,
    required this.ingredientCategory,
    this.mealId,
    this.title,
    this.meal,
  });
}