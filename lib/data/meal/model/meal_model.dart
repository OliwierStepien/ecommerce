import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';

part 'meal_model.g.dart';

@HiveType(typeId: 2)
class MealModel {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String mealId;
  @HiveField(2)
  final List<String> categoryId;
  @HiveField(3)
  final String image;
  @HiveField(4)
  final List<IngredientModel> ingredients;
  @HiveField(5)
  final List<String> steps;
  @HiveField(6)
  final bool isVegetarian;

  MealModel({
    required this.title,
    required this.mealId,
    required this.categoryId,
    required this.image,
    required this.ingredients,
    required this.steps,
    required this.isVegetarian,
  });

  MealModel copyWith({
    String? title,
    String? mealId,
    List<String>? categoryId,
    String? image,
    List<IngredientModel>? ingredients,
    List<String>? steps,
    bool? isVegetarian,
  }) {
    return MealModel(
      title: title ?? this.title,
      mealId: mealId ?? this.mealId,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mealId': mealId,
      'categoriesId': categoryId,
      'image': image,
      'steps': steps,
      'isVegetarian': isVegetarian,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    List<IngredientModel> ingredients = [];
    if (map['ingredients'] != null) {
      ingredients = (map['ingredients'] as List<dynamic>).map((ingredientMap) {
        return IngredientModel.fromMap(ingredientMap as Map<String, dynamic>);
      }).toList();
    }

    return MealModel(
      title: map['title'] as String,
      mealId: map['mealId'] as String,
      categoryId: List<String>.from(map['categoriesId'] as List<dynamic>),
      image: map['image'] as String,
      ingredients: ingredients,
      steps: List<String>.from(map['steps'] as List<dynamic>),
      isVegetarian: map['isVegetarian'] as bool,
    );
  }
}
