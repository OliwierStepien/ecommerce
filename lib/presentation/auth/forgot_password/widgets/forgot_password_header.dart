import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.resetPassword,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}