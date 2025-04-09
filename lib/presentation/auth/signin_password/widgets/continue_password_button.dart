import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/button/basic_reactive_button.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/domain/auth/usecases/signin.dart';

class ContinuePasswordButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final UserSigninReq userSigninReq;
  const ContinuePasswordButton({
    super.key,
    required this.formKey,
    required this.controller,
    required this.userSigninReq,
  });

  @override
  Widget build(BuildContext context) {
    return BasicReactiveButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          userSigninReq.password = controller.text;
          context
              .read<ButtonStateCubit>()
              .execute(usecase: SigninUsecase(), params: userSigninReq);
        }
      },
      title: 'Kontynuuj',
    );
  }
}
