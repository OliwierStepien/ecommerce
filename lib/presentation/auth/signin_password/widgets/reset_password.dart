import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/routes/routes.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.muted, fontSize: 14),
        children: [
          TextSpan(text: context.l10n.forgotPassword),
          TextSpan(
            text: context.l10n.resetPassword,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.push(Routes.forgotPasswordPage);
              },
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
