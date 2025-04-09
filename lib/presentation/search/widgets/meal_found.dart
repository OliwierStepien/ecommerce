import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

class MealFound extends StatelessWidget {
  final List<MealEntity> meals;
  const MealFound({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
  return GridView.builder(
    itemCount: meals.length,
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6),
    itemBuilder: (BuildContext context, int index) {
      return MealCard(mealEntity: meals[index]);
    },
  );
  }
}