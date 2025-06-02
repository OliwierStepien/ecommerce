import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninEmailHeader extends StatelessWidget {
  const SigninEmailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.signIn,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}
