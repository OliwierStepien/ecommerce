import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({
    super.key,
    required this.plannedMeals,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  /// Mapowanie: znormalizowana data -> lista zaplanowanych posiłków
  final Map<DateTime, List<PlannedMealEntity>> plannedMeals;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'pl_PL',
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,

      // Eventy dla dnia – korzystamy ze znormalizowanego klucza
      eventLoader: (day) {
        final normalized = DateTime(day.year, day.month, day.day);
        return plannedMeals[normalized] ?? [];
      },

      // Kropka-znacznik jeśli są eventy
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return const Positioned(
              top: 1,
              child: SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}