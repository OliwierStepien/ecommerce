import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_state.dart';
import 'package:mealapp/presentation/planned_meal/widgets/meal_list_item.dart';
import 'package:table_calendar/table_calendar.dart';

class PlannedMealPage extends StatelessWidget {
  final MealEntity? mealToAdd;

  const PlannedMealPage({super.key, this.mealToAdd});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannedMealsCubit, PlannedMealsState>(
      builder: (context, state) {
        final cubit = context.read<PlannedMealsCubit>();
        final plannedMeals =
            (state is PlannedMealsLoaded) ? state.plannedMeals : {};
        final selectedDay =
            (state is PlannedMealsLoaded) ? state.selectedDay : DateTime.now();
        final focusedDay =
            (state is PlannedMealsLoaded) ? state.focusedDay : DateTime.now();

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.calendar),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Remove meals in date range',
                onPressed: () async {
                  final pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.utc(2025, 1, 1),
                    lastDate: DateTime.utc(2035, 12, 31),
                    initialDateRange: DateTimeRange(
                      start: DateTime.now().isBefore(DateTime.utc(2025, 1, 1))
                          ? DateTime.utc(2025, 1, 1)
                          : DateTime.now(),
                      end: DateTime.now().add(const Duration(days: 1)),
                    ),
                    helpText: 'Wybierz zakres dat do usunięcia',
                  );
                  if (pickedRange != null) {
                    await cubit.removePlannedMealsInDateRange(
                      pickedRange.start,
                      pickedRange.end,
                      (message) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TableCalendar(
                      locale: "pl_PL",
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                      firstDay: DateTime.utc(2025, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (selected, focused) {
                        cubit.changeDay(selected, focused);
                      },
                      onPageChanged: (focused) {
                        cubit.changeDay(selectedDay, focused);
                      },

                      // 🔹 Ładowanie eventów dla danego dnia
                      eventLoader: (day) {
                        final normalized =
                            DateTime(day.year, day.month, day.day);
                        return plannedMeals[normalized] ?? [];
                      },

                      // 🔹 Custom marker (jedna kropka jeśli są eventy)
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              top: 1,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple, // kolor kropki
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    if (mealToAdd != null)
                      Center(
                        child: ElevatedButton(
                          onPressed: () => cubit.addPlannedMeal(
                            PlannedMealEntity(
                              date: selectedDay,
                              meal: mealToAdd!,
                            ),
                            context,
                          ),
                          child: Text(context.l10n.addMealToDay),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if ((plannedMeals[selectedDay] ?? []).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.l10n.plannedMeals,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shrinkWrap:
                                true, // ważne, żeby działało wewnątrz scrolla
                            physics:
                                const NeverScrollableScrollPhysics(), // przewija się cały ekran
                            itemCount: plannedMeals[selectedDay]!.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final plannedMeal =
                                  plannedMeals[selectedDay]![index];
                              return MealListItem(
                                mealEntity: plannedMeal.meal,
                                onRemove: () async {
                                  final success = await cubit
                                      .removePlannedMeal(plannedMeal);
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Meal removed from plan successfully.'
                                            : 'Error removing meal.',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
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
