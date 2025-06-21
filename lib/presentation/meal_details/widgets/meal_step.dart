import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class MealStep extends StatelessWidget {
  final MealEntity mealEntity;
  const MealStep({
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              context.l10n.cookingSteps,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...mealEntity.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• $step',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
