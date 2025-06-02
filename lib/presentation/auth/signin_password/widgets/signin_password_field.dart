import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninPasswordField extends StatelessWidget {
  final TextEditingController controller;
  const SigninPasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: context.l10n.enterPassword,
        border: const OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pole nie może być puste';
        }
        return null;
      },
    );
  }
}
