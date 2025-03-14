import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/button/basic_reactive_button.dart';
import 'package:mealapp/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mealapp/presentation/auth/pages/password_reset_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 40,
          ),
          child: BlocProvider(
            create: (context) => ButtonStateCubit(),
            child: BlocListener<ButtonStateCubit, ButtonState>(
              listener: (context, state) {
                if (state is ButtonFailureState) {
                  final snackbar = SnackBar(
                    content: Text(state.errorMessage),
                    behavior: SnackBarBehavior.floating,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }
                if (state is ButtonSuccessState) {
                  AppNavigator.push(context, const PasswordResetEmailPage());
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _signinText(context),
                  const SizedBox(height: 20),
                  _emailField(context),
                  const SizedBox(height: 20),
                  _continueButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signinText(BuildContext context) {
    return const Text(
      'Zresetuj hasło',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _emailCon,
      decoration: const InputDecoration(
        hintText: 'Podaj adres Email',
      ),
    );
  }

  Widget _continueButton() {
    return Builder(builder: (context) {
      return BasicReactiveButton(
        onPressed: () {
          context.read<ButtonStateCubit>().execute(
                usecase: SendPasswordResetEmailUseCase(),
                params: _emailCon.text,
              );
        },
        title: 'Kontynuuj',
      );
    });
  }
}
