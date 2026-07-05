import 'package:go_router/go_router.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/continue_password_button.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/signin_password_field.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/reset_password.dart';
import 'package:mealapp/presentation/auth/signin_password/widgets/signin_password_header.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
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
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: BlocProvider(
            create: (context) => ButtonStateCubit(),
            child: BlocListener<ButtonStateCubit, ButtonState>(
              listener: (context, state) async {
                if (state is ButtonFailureState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                if (state is ButtonSuccessState) {
                  // 1) Pokaż feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // 2) ODŚWIEŻ DANE UŻYTKOWNIKA PRZED NAWIGACJĄ
                  // (UserInfoDisplayCubit jest dostarczony globalnie w MyAppWrapper)
                  try {
                    await context.read<UserInfoDisplayCubit>().displayUserInfo();
                  } catch (_) {
                    // jeśli z jakiegoś powodu nie ma w context — możesz ewentualnie użyć get_it
                    // sl<UserInfoDisplayCubit>().displayUserInfo();
                  }

                  // 3) Dopiero teraz przejdź na Home
                  if (context.mounted) {
                    context.go(Routes.homePage);
                  }
                }
              },
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SigninPasswordHeader(email: userSigninReq.email),
                    const SizedBox(height: 20),
                    SigninPasswordField(controller: _passwordCon),
                    const SizedBox(height: 20),
                    ContinuePasswordButton(
                      formKey: _formKey,
                      controller: _passwordCon,
                      userSigninReq: userSigninReq,
                    ),
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