import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final String title;
  final String mealId;
  final List<String> categoryId;
  final String image;
  final List<String> ingredients;
  final List<String> steps;
  final bool isVegetarian;

  const MealEntity({
    required this.title,
    required this.mealId,
    required this.categoryId,
    required this.image,
    required this.ingredients,
    required this.steps,
    required this.isVegetarian,
  });

  @override
  List<Object?> get props =>
      [title, mealId, categoryId, image, ingredients, steps, isVegetarian];
}
