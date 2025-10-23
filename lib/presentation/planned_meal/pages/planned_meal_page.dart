import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_state.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/planned_meal/widgets/add_meal_button.dart';
import 'package:mealapp/presentation/planned_meal/widgets/calendar_section.dart';
import 'package:mealapp/presentation/planned_meal/widgets/clear_range_button.dart';
import 'package:mealapp/presentation/planned_meal/widgets/meals_list_section.dart';

class PlannedMealPage extends StatelessWidget {
  final MealEntity? mealToAdd;

  const PlannedMealPage({super.key, this.mealToAdd});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannedMealsCubit, PlannedMealsState>(
      builder: (context, state) {
        final cubit = context.read<PlannedMealsCubit>();

        // 🔹 Jawny typ Map<DateTime, List<PlannedMealEntity>>
        final Map<DateTime, List<PlannedMealEntity>> plannedMeals =
            (state is PlannedMealsLoaded)
                ? state.plannedMeals
                : <DateTime, List<PlannedMealEntity>>{};

        final selectedDay =
            (state is PlannedMealsLoaded) ? state.selectedDay : DateTime.now();
        final focusedDay =
            (state is PlannedMealsLoaded) ? state.focusedDay : DateTime.now();

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.calendar),
            actions: [
              ClearRangeButton(onConfirm: (start, end, onFeedback) async {
                await cubit.removePlannedMealsInDateRange(start, end,
                    (message) {
                  if (!context.mounted) return;
                  onFeedback(message);
                });
              }),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarSection(
                      plannedMeals: plannedMeals,
                      selectedDay: selectedDay,
                      focusedDay: focusedDay,
                      onDaySelected: (selected, focused) =>
                          cubit.changeDay(selected, focused),
                      onPageChanged: (newFocused) =>
                          cubit.changeDay(selectedDay, newFocused),
                    ),
                    if (mealToAdd != null)
                      Center(
                        child: AddMealButton(
                          label: context.l10n.addMealToDay,
                          onPressed: () => cubit.addPlannedMeal(
                            PlannedMealEntity(
                              date: selectedDay,
                              meal: mealToAdd!,
                            ),
                            context,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // 🔹 Użycie znormalizowanej daty przy odczycie
                    MealsListSection(
                      plannedMealsForSelectedDay: plannedMeals[DateTime(
                              selectedDay.year,
                              selectedDay.month,
                              selectedDay.day)] ??
                          const [],
                      onRemove: (plannedMeal) async {
                        final success =
                            await cubit.removePlannedMeal(plannedMeal);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Meal removed from plan successfully.'
                                  : 'Error removing meal.',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
