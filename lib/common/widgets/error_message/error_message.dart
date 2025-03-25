import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorMessage({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 40,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: themeData.textTheme.displaySmall?.copyWith(
              color: Colors.white,
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