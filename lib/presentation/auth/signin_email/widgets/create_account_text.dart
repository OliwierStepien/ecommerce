import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/routes/routes.dart';

class CreateAccountText extends StatelessWidget {
  const CreateAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: context.l10n.doNotHaveAccount),
          TextSpan(
            text: context.l10n.createNew,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.push(Routes.signUpPage);
              },
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
