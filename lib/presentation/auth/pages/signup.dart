import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/button/basic_reactive_button.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:mealapp/domain/auth/usecases/signup.dart';
import 'package:mealapp/presentation/auth/pages/signin_login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController _firstNameCon = TextEditingController();
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocProvider(
          create: (context) => ButtonStateCubit(),
          child: Builder(
            builder: (context) {
              return BlocListener<ButtonStateCubit, ButtonState>(
                listener: (context, state) {
                  if (state is ButtonFailureState) {
                    final snackbar = SnackBar(
                      content: Text(state.errorMessage),
                      behavior: SnackBarBehavior.floating,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  }
                  if (state is ButtonSuccessState) {
                    final snackbar = SnackBar(
                      content: Text(state.successMessage),
                      behavior: SnackBarBehavior.floating,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    AppNavigator.pushReplacement(context, SignInLoginPage());
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 40,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _signinText(context),
                        const SizedBox(height: 20),
                        _firstNameField(context),
                        const SizedBox(height: 20),
                        _emailField(context),
                        const SizedBox(height: 20),
                        _passwordField(context),
                        const SizedBox(height: 20),
                        _finishButton(context),
                        const SizedBox(height: 20),
                        _createAccount(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _signinText(BuildContext context) {
    return const Text(
      'Stwórz konto',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _firstNameField(BuildContext context) {
    return TextFormField(
      controller: _firstNameCon,
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

Widget _emailField(BuildContext context) {
  return TextFormField(
    controller: _emailCon,
    decoration: const InputDecoration(
      hintText: 'Email',
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

  Widget _passwordField(BuildContext context) {
    return TextFormField(
      controller: _passwordCon,
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

  Widget _finishButton(BuildContext context) {
  return BasicReactiveButton(
    onPressed: () {
      if (_formKey.currentState!.validate()) {
        context.read<ButtonStateCubit>().execute(
              usecase: SignupUsecase(),
              params: UserCreationReq(
                firstName: _firstNameCon.text,
                email: _emailCon.text,
                password: _passwordCon.text,
              ),
            );
      }
    },
    title: 'Utwórz konto',
  );
}

  Widget _createAccount(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: 'Masz konto? '),
          TextSpan(
            text: 'Zaloguj się',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppNavigator.pushReplacement(context, SignInLoginPage());
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
