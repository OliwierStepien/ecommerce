import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/routes/routes.dart';

class SignInEmailPage extends StatelessWidget {
  SignInEmailPage({super.key});

  final TextEditingController _emailCon = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(hideBack: true),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _signinText(),
                const SizedBox(height: 20),
                _emailField(),
                const SizedBox(height: 20),
                _continueButton(context),
                const SizedBox(height: 20),
                _createAccount(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signinText() {
    return const Text(
      'Zaloguj się',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailCon,
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

  Widget _continueButton(BuildContext context) {
    return BasicAppButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.push(Routes.signInPasswordPage,
              extra: UserSigninReq(email: _emailCon.text));
        }
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
                context.push(Routes.signUpPage);
              },
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
