import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class ResetEmailField extends StatelessWidget {
  final TextEditingController controller;
  const ResetEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Podaj adres Email',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pole nie może być puste';
        }
        if (!value.contains('@')) {
          return context.l10n.enterEmailAddress;
        }
        return null;
      },
    );
  }
}