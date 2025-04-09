import 'package:go_router/go_router.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/continue_password_button.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/signin_password_field.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/reset_password.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/signin_password_header.dart';
import 'package:mealapp/routes/routes.dart';

class SignInPasswordPage extends StatelessWidget {
  final UserSigninReq userSigninReq;
  SignInPasswordPage({
    super.key,
    required this.userSigninReq,
  });

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
                  final snackbar = SnackBar(
                    content: Text(state.successMessage),
                    behavior: SnackBarBehavior.floating,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  context.go(Routes.homePage);
                }
              },
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SigninPasswordHeader(),
                    const SizedBox(height: 20),
                    SigninPasswordField(controller: _passwordCon),
                    const SizedBox(height: 20),
                    ContinuePasswordButton(
                        formKey: _formKey,
                        controller: _passwordCon,
                        userSigninReq: userSigninReq),
                    const SizedBox(height: 20),
                    const ResetPassword(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
