import 'package:hive/hive.dart';
import 'package:mealapp/data/ingredient/model/ingredient_model.dart';

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
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'steps': steps,
      'isVegetarian': isVegetarian,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      title: map['title']?.toString() ?? '',
      mealId: map['mealId']?.toString() ?? '',
      categoryId: _parseStringList(map['categoriesId']),
      image: map['image']?.toString() ?? '',
      ingredients: _parseIngredientList(map['ingredients']),
      steps: _parseStringList(map['steps']),
      isVegetarian: map['isVegetarian'] == true,
    );
  }

  static List<String> _parseStringList(dynamic data) {
    if (data is List) {
      return data.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }

static List<IngredientModel> _parseIngredientList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(IngredientModel.fromMap)
        .toList();
  }
  return [];
}
}
