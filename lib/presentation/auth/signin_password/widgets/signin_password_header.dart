import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninPasswordHeader extends StatelessWidget {
  const SigninPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.signIn,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}