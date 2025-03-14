import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/button/basic_reactive_button.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/domain/auth/usecases/signin.dart';
import 'package:mealapp/presentation/auth/pages/forgot_password.dart';
import 'package:mealapp/presentation/home/pages/home.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnterPasswordPage extends StatelessWidget {
  final UserSigninReq userSigninReq;
  EnterPasswordPage({
    super.key,
    required this.userSigninReq,
  });

  final TextEditingController _passwordCon = TextEditingController();

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
                  AppNavigator.pushAndRemove(context, const HomePage());
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _signinText(context),
                  const SizedBox(height: 20),
                  _passwordField(context),
                  const SizedBox(height: 20),
                  _continueButton(),
                  const SizedBox(height: 20),
                  _forgotPassword(context),
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
      'Zaloguj się',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _passwordCon,
      decoration: const InputDecoration(
        hintText: 'Podaj hasło',
      ),
      obscureText: true,
    );
  }

  Widget _continueButton() {
    return Builder(builder: (context) {
      return BasicReactiveButton(
        onPressed: () {
          userSigninReq.password = _passwordCon.text;
          context
              .read<ButtonStateCubit>()
              .execute(usecase: SigninUsecase(), params: userSigninReq);
        },
        title: 'Kontynuuj',
      );
    });
  }

  Widget _forgotPassword(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: 'Zapomniałeś hasła? '),
          TextSpan(
            text: 'Zresetuj hasło',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppNavigator.push(context, ForgotPasswordPage());
              },
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
