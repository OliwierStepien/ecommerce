import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class ResetEmailField extends StatelessWidget {
  final TextEditingController controller;
  const ResetEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('EMAIL'),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Podaj adres Email',
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
        ),
      ],
    );
  }
}
