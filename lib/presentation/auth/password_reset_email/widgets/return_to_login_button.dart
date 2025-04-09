import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';
import 'package:mealapp/routes/routes.dart';

class ReturnToLoginButton extends StatelessWidget {
  const ReturnToLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicAppButton(
        onPressed: () {
          context.go(Routes.signInEmailPage);
        },
        width: 200,
        title: 'Wróć do strony logowania');
  }
}
