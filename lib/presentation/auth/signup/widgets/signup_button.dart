import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/button/basic_reactive_button.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:mealapp/domain/auth/usecases/signup.dart';

class SignupButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignupButton({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BasicReactiveButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          context.read<ButtonStateCubit>().execute(
                usecase: SignupUsecase(),
                params: UserCreationReq(
                  firstName: firstNameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                ),
              );
        }
      },
      title: 'Utwórz konto',
    );
  }
}