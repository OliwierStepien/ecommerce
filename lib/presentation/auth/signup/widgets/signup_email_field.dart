import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SignupEmailField extends StatelessWidget {
  final TextEditingController controller;
  const SignupEmailField({super.key, required this.controller});

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
          decoration: InputDecoration(
            hintText: context.l10n.email,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.fieldCannotBeEmpty;
            }
            if (!value.contains('@')) {
              return 'Wprowadź poprawny adres email';
            }
            return null;
          },
        ),
      ],
    );
  }
}
