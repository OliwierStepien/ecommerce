import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:flutter/material.dart';

class MealTitle extends StatelessWidget {
  final MealEntity mealEntity;
  const MealTitle({
    required this.mealEntity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      mealEntity.title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 26,
      ),
    );
  }
}
