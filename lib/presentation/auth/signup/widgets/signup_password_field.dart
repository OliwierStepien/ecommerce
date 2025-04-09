import 'package:flutter/material.dart';

class SignupPasswordField extends StatelessWidget {
  final TextEditingController controller;
  const SignupPasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Hasło',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pole nie może być puste';
        }
        return null;
      },
    );
  }
}