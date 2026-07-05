import 'package:flutter/material.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';

class EmailSending extends StatelessWidget {
  const EmailSending({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          color: AppColors.softFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.hairline),
        ),
        child: const Icon(
          Icons.mark_email_read,
          size: 46,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
