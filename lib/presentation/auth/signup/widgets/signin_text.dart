import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/routes/routes.dart';

class SigninText extends StatelessWidget {
  const SigninText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: context.l10n.alreadyHaveAccount),
          TextSpan(
            text: context.l10n.signIn,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.go(Routes.signInEmailPage);
              },
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}