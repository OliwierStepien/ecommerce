import 'package:flutter/material.dart';

class SignupFirstNameField extends StatelessWidget {
  final TextEditingController controller;
  const SignupFirstNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Imię',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pole nie może być puste';
        }
        return null;
      },
    );
  }
}