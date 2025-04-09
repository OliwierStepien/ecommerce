import 'package:flutter/material.dart';

class SigninPasswordHeader extends StatelessWidget {
  const SigninPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Zaloguj się',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}