import 'package:flutter/material.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/presentation/planned_meal/widgets/meal_list_item.dart';

class MealsListSection extends StatelessWidget {
  const MealsListSection({
    super.key,
    required this.plannedMealsForSelectedDay,
    required this.onRemove,
  });

  final List<PlannedMealEntity> plannedMealsForSelectedDay;
  final Future<void> Function(PlannedMealEntity plannedMeal) onRemove;

  @override
  Widget build(BuildContext context) {
    if (plannedMealsForSelectedDay.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Planned meals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plannedMealsForSelectedDay.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final plannedMeal = plannedMealsForSelectedDay[index];
            return MealListItem(
              mealEntity: plannedMeal.meal,
              onRemove: () async => onRemove(plannedMeal),
            );
          },
        ),
      ],
    );
  }
}