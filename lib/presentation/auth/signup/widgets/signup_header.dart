import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.createAccount,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}