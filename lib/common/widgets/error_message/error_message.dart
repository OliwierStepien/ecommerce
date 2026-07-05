import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorMessage({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 40,
            color: AppColors.danger,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            Column(
              children: [
                const SizedBox(height: 20),
                BasicAppButton(
                  onPressed: onRetry!,
                  title: 'Ponów próbę',
                  height: 50,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
