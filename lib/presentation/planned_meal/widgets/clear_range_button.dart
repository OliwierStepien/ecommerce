import 'package:flutter/material.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';

class ClearRangeButton extends StatelessWidget {
  const ClearRangeButton({
    super.key,
    required this.onConfirm,
  });

  final Future<void> Function(
    DateTime start,
    DateTime end,
  ) onConfirm;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.event_busy, color: AppColors.muted),
      tooltip: 'Usuń posiłki w wybranym zakresie dat',
      onPressed: () async {
        final now = DateTime.now();
        final initialStart = now.isBefore(DateTime.utc(2025, 1, 1))
            ? DateTime.utc(2025, 1, 1)
            : now;

        final pickedRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime.utc(2025, 1, 1),
          lastDate: DateTime.utc(2035, 12, 31),
          initialDateRange: DateTimeRange(
            start: initialStart,
            end: now.add(const Duration(days: 1)),
          ),
          helpText: 'Wybierz zakres dat do usunięcia',
        );

        if (pickedRange != null) {
          await onConfirm(pickedRange.start, pickedRange.end);
        }
      },
    );
  }
}
