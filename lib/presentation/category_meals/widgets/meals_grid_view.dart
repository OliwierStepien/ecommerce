import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

class MealsGridView extends StatelessWidget {
  final List<MealEntity> meals;
  const MealsGridView({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: meals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.6),
        itemBuilder: (BuildContext context, int index) {
          return MealCard(mealEntity: meals[index]);
        },
      ),
    );
  }
}
