import 'package:flutter/material.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Zresetuj hasło',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}