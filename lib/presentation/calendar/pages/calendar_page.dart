import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.calendar),
      ),
      body: SafeArea(
        child: TableCalendar(
          focusedDay: today,
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
        ),
      ),
    );
  }
}