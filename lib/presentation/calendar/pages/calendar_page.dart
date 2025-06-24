import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/calendar/bloc/planned_meals_cubit.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final MealEntity? mealToAdd;

  const CalendarPage({super.key, this.mealToAdd});

  @override
  State<CalendarPage> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = normalizeDate(_focusedDay);
    _selectedDay = _focusedDay;
  }

  void _addMeal() {
    if (_selectedDay != null && widget.mealToAdd != null) {
      final selected = normalizeDate(_selectedDay!);
      context.read<PlannedMealsCubit>().addMeal(selected, widget.mealToAdd!);
    }
  }

  void _removeMeal(MealEntity meal) {
    if (_selectedDay != null) {
      final selected = normalizeDate(_selectedDay!);
      context.read<PlannedMealsCubit>().removeMeal(selected, meal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedDay = normalizeDate(_selectedDay!);
    final mealsForDay = context.select<PlannedMealsCubit, List<MealEntity>>(
      (cubit) => cubit.state[normalizedDay] ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.calendar),
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
                      titleCentered: true, formatButtonVisible: false),
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = normalizeDate(selectedDay);
                      _focusedDay = normalizeDate(focusedDay);
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = normalizeDate(focusedDay);
                  },
                ),
                if (widget.mealToAdd != null)
                  Center(
                    child: ElevatedButton(
                      onPressed: _addMeal,
                      child: const Text("Dodaj posiłek do dnia"),
                    ),
                  ),
                const SizedBox(height: 16),
                if (mealsForDay.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Zaplanowane posiłki',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: mealsForDay.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final meal = mealsForDay[index];
                            return Stack(
                              children: [
                                MealCard(mealEntity: meal),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close,
                                          size: 18),
                                      onPressed: () => _removeMeal(meal),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}