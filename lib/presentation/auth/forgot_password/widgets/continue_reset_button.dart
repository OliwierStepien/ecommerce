import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/button/basic_reactive_button.dart';
import 'package:mealapp/domain/auth/usecases/send_password_reset_email.dart';

class ContinueResetButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  const ContinueResetButton({super.key, 
    required this.formKey,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BasicReactiveButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          context.read<ButtonStateCubit>().execute(
                usecase: SendPasswordResetEmailUseCase(),
                params: controller.text,
              );
        }
      },
      title: 'Kontynuuj',
    );
  }
}
