import 'package:go_router/go_router.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/auth/signup/widgets/signin_text.dart';
import 'package:mealapp/presentation/auth/signup/widgets/signup_button.dart';
import 'package:mealapp/presentation/auth/signup/widgets/signup_email_field.dart';
import 'package:mealapp/presentation/auth/signup/widgets/signup_first_name_field.dart';
import 'package:mealapp/presentation/auth/signup/widgets/signup_header.dart';
import 'package:mealapp/presentation/auth/signup/widgets/signup_password_field.dart';
import 'package:mealapp/routes/routes.dart';

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
                    context.go(Routes.signInEmailPage);
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
                        const SignupHeader(),
                        const SizedBox(height: 20),
                        SignupFirstNameField(
                          controller: _firstNameCon,
                        ),
                        const SizedBox(height: 20),
                        SignupEmailField(
                          controller: _emailCon,
                        ),
                        const SizedBox(height: 20),
                        SignupPasswordField(controller: _passwordCon),
                        const SizedBox(height: 20),
                        SignupButton(
                          formKey: _formKey,
                          firstNameController: _firstNameCon,
                          emailController: _emailCon,
                          passwordController: _passwordCon,
                        ),
                        const SizedBox(height: 20),
                        const SigninText(),
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
}
