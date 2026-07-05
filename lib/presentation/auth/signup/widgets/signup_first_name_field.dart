import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SignupFirstNameField extends StatelessWidget {
  final TextEditingController controller;
  const SignupFirstNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('IMIĘ'),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Imię',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.enterValidEmailAddress;
            }
            return null;
          },
        ),
      ],
    );
  }
}
