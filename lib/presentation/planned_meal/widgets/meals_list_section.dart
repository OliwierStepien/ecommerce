// presentation/planned_meal/widgets/meals_list_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/planned_meal/widgets/meal_list_item.dart';

class MealsListSection extends StatelessWidget {
  const MealsListSection({
    super.key,
    required this.plannedMealsForSelectedDay,
    required this.selectedDate, // 👈 Dodajemy datę
    required this.onRemove,
  });

  final List<PlannedMealEntity> plannedMealsForSelectedDay;
  final DateTime selectedDate; // 👈 Data wybranego dnia
  final Future<void> Function(PlannedMealEntity plannedMeal) onRemove;

  @override
  Widget build(BuildContext context) {
    if (plannedMealsForSelectedDay.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sortuj według pozycji
    final sortedMeals = List<PlannedMealEntity>.from(plannedMealsForSelectedDay)
      ..sort((a, b) => a.position.compareTo(b.position));

    final formattedDate =
        DateFormat('EEEE d MMMM', 'pl_PL').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(bottom: 6),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.hairline)),
          ),
          child: Text(
            'Zaplanowane · $formattedDate',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedMeals.length,
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            context.read<PlannedMealsCubit>().reorderPlannedMeals(
              oldIndex: oldIndex,
              newIndex: newIndex,
              date: selectedDate,
            );
          },
          itemBuilder: (context, index) {
            final plannedMeal = sortedMeals[index];
            return MealListItem(
              key: ValueKey('${plannedMeal.date}_${plannedMeal.meal.mealId}'),
              mealEntity: plannedMeal.meal,
              onRemove: () async => onRemove(plannedMeal),
              // 👇 Uchwyt do przeciągania
              dragHandle: ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.drag_handle,
                    size: 20,
                    color: Color(0xFFB3A58F),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
