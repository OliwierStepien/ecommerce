import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninEmailField extends StatelessWidget {
  final TextEditingController controller;
  const SigninEmailField({super.key, required this.controller});

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
            hintText: context.l10n.enterEmailAddress,
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
        ),
      ],
    );
  }
}
