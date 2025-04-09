import 'package:flutter/material.dart';

class SignupEmailField extends StatelessWidget {
  final TextEditingController controller;
  const SignupEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Email',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pole nie może być puste';
        }
        if (!value.contains('@')) {
          return 'Wprowadź poprawny adres email';
        }
        return null;
      },
    );
  }
}
