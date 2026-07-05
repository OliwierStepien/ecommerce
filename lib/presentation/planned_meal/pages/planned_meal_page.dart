import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
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
    return BlocListener<PlannedMealsCubit, PlannedMealsState>(
      listenWhen: (prev, curr) =>
          curr is PlannedMealsLoaded &&
          (curr.toastMessage != null && curr.toastMessage!.isNotEmpty),
      listener: (context, state) {
        if (state is PlannedMealsLoaded && state.toastMessage != null) {
          // Strona kalendarza żyje w kilku instancjach naraz (gałąź dolnej
          // nawigacji w IndexedStack + wariant push-nięty z detali dania),
          // a wszystkie słuchają tego samego cubita — snackbar pokazuje
          // tylko instancja aktualnie widoczna na ekranie.
          final isVisible = TickerMode.of(context) &&
              (ModalRoute.of(context)?.isCurrent ?? true);
          if (!isVisible) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: BlocBuilder<PlannedMealsCubit, PlannedMealsState>(
        builder: (context, state) {
          final cubit = context.read<PlannedMealsCubit>();

          if (state is PlannedMealsLoading || state is PlannedMealsInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is PlannedMealsError) {
            return Scaffold(
              appBar: AppBar(title: Text(context.l10n.calendar)),
              body: Center(child: Text(state.message)),
            );
          }

          final loaded = state as PlannedMealsLoaded;

          final Map<DateTime, List<PlannedMealEntity>> plannedMeals =
              loaded.plannedMeals;

          final selectedDay = loaded.selectedDay;
          final focusedDay = loaded.focusedDay;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 76,
              centerTitle: false,
              titleSpacing: 16,
              automaticallyImplyLeading: Navigator.of(context).canPop(),
              iconTheme: const IconThemeData(color: AppColors.ink),
              title: PageHeader(
                kicker: 'PLAN POSIŁKÓW',
                title: context.l10n.calendar,
              ),
              actions: [
                ClearRangeButton(
                  onConfirm: (start, end) async {
                    await cubit.removePlannedMealsInDateRange(start, end);
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
                                position: plannedMeals[selectedDay]?.length ?? 0,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      MealsListSection(
                        plannedMealsForSelectedDay: plannedMeals[DateTime(
                              selectedDay.year,
                              selectedDay.month,
                              selectedDay.day,
                            )] ??
                            const [],
                        selectedDate: selectedDay, // 👈 Przekazujemy datę
                        onRemove: (plannedMeal) async {
                          await cubit.removePlannedMeal(plannedMeal);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
