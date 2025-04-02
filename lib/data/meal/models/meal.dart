import 'package:hive/hive.dart';

part 'meal.g.dart';

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
  final List<String> ingredients;
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

    Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mealId': mealId,
      'categoriesId': categoryId,
      'image': image,
      'ingredients': ingredients,
      'steps': steps,
      'isVegetarian': isVegetarian,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      title: map['title'] as String,
      mealId: map['mealId'] as String,
      categoryId: List<String>.from(map['categoriesId'] as List<dynamic>),
      image: map['image'] as String,
      ingredients: List<String>.from(map['ingredients'] as List<dynamic>),
      steps: List<String>.from(map['steps'] as List<dynamic>),
      isVegetarian: map['isVegetarian'] as bool,
    );
  }
}