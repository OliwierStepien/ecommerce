import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SignupPasswordField extends StatefulWidget {
  final TextEditingController controller;
  const SignupPasswordField({super.key, required this.controller});

  @override
  State<SignupPasswordField> createState() => _SignupPasswordFieldState();
}

class _SignupPasswordFieldState extends State<SignupPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('HASŁO'),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: context.l10n.password,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: _obscure ? AppColors.muted : AppColors.accent,
              ),
            ),
          ),
          obscureText: _obscure,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.fieldCannotBeEmpty;
            }
            return null;
          },
        ),
      ],
    );
  }
}
