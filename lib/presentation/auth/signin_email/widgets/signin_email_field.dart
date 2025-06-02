import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninEmailField extends StatelessWidget {
  final TextEditingController controller;
  const SigninEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: context.l10n.enterEmailAddress,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.fieldCannotBeEmpty;
        }
        if (!value.contains('@')) {
          return context.l10n.enterValidEmailAddress;
        }
        return null;
      },
    );
  }
}