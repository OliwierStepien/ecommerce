import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/presentation/auth/pages/enter_password.dart';
import 'package:mealapp/presentation/auth/pages/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: const BasicAppbar(
      hideBack: true,
    ),
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _signinText(context),
            const SizedBox(height: 20),
            _emailField(context),
            const SizedBox(height: 20),
            _continueButton(context),
            const SizedBox(height: 20),
            _createAccount(context),
          ],
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

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _emailCon,
      decoration: const InputDecoration(
        hintText: 'Podaj adres Email',
      ),
    );
  }

  Widget _continueButton(BuildContext context) {
    return BasicAppButton(
      onPressed: () {
        AppNavigator.push(
          context,
          EnterPasswordPage(
            userSigninReq: UserSigninReq(
              email: _emailCon.text,
            ),
          ),
        );
      },
      title: 'Kontynuuj',
    );
  }

  Widget _createAccount(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: 'Nie masz konta? '),
          TextSpan(
            text: 'Stwórz nowe',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppNavigator.push(context, SignUpPage());
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
