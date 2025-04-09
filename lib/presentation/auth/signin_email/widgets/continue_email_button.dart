import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/routes/routes.dart';

class ContinueEmailButton extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  const ContinueEmailButton({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return BasicAppButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          context.push(Routes.signInPasswordPage,
              extra: UserSigninReq(email: controller.text));
        }
      },
      title: 'Kontynuuj',
    );
  }
}