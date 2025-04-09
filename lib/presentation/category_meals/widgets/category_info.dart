import 'package:flutter/material.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

class CategoryInfo extends StatelessWidget {
  final CategoryEntity categoryEntity;
  final List<MealEntity> meals;
  const CategoryInfo({
    super.key,
    required this.categoryEntity,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${categoryEntity.title} (${meals.length})',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
