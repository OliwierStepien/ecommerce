import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SignupPasswordField extends StatelessWidget {
  final TextEditingController controller;
  const SignupPasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: context.l10n.password,
        border: const OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.fieldCannotBeEmpty;
        }
        return null;
      },
    );
  }
}