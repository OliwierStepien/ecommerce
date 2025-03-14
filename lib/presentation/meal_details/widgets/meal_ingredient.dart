import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:flutter/material.dart';

class MealIngredient extends StatelessWidget {
  final MealEntity mealEntity;
  const MealIngredient({
    super.key,
    required this.mealEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "Składniki:",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
              ),
            ),
          ),
          ...mealEntity.ingredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• $ingredient',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}