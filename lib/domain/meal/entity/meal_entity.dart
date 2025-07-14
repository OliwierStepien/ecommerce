import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';

class MealEntity extends Equatable {
  final String title;
  final String mealId;
  final List<String> categoryId;
  final String image;
  final List<IngredientEntity> ingredients;
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

  MealEntity copyWith({
    String? title,
    String? mealId,
    List<String>? categoryId,
    String? image,
    List<IngredientEntity>? ingredients,
    List<String>? steps,
    bool? isVegetarian,
  }) {
    return MealEntity(
      title: title ?? this.title,
      mealId: mealId ?? this.mealId,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }

  @override
  List<Object?> get props =>
      [title, mealId, categoryId, image, ingredients, steps, isVegetarian];
}
