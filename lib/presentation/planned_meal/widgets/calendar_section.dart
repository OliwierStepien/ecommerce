import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mealapp/core/configs/theme/app_colors.dart';
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
    final dowStyle = GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.8,
      color: AppColors.accent,
    );

    return TableCalendar(
      locale: 'pl_PL',
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        leftChevronIcon:
            const Icon(Icons.chevron_left, color: AppColors.muted),
        rightChevronIcon:
            const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
      daysOfWeekHeight: 28,
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (date, locale) =>
            DateFormat.E(locale).format(date).toUpperCase(),
        weekdayStyle: dowStyle,
        weekendStyle: dowStyle,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
      ),
      calendarStyle: TextStyleCalendarStyle.base,
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
                    color: AppColors.accent,
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

/// Styl dni kalendarza w palecie „Brąz z klasą".
abstract class TextStyleCalendarStyle {
  static const base = CalendarStyle(
    defaultTextStyle: TextStyle(color: AppColors.ink),
    weekendTextStyle: TextStyle(color: AppColors.ink),
    outsideTextStyle: TextStyle(color: AppColors.muted),
    todayDecoration: BoxDecoration(
      color: AppColors.softFill,
      shape: BoxShape.circle,
    ),
    todayTextStyle: TextStyle(color: AppColors.ink),
    selectedDecoration: BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    selectedTextStyle: TextStyle(color: AppColors.background),
  );
}
