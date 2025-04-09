import 'package:flutter/material.dart';

class SigninEmailField extends StatelessWidget {
  final TextEditingController controller;
  const SigninEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Podaj adres Email',
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