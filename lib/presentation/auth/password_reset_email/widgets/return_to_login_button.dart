import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/routes/routes.dart';

class ReturnToLoginButton extends StatelessWidget {
  const ReturnToLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.go(Routes.signInEmailPage);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(240, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Text(context.l10n.backToLoginPage),
    );
  }
}
