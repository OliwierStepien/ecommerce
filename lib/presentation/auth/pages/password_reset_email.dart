import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/common/widgets/button/basic_app_button.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';
import 'package:mealapp/presentation/auth/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PasswordResetEmailPage extends StatelessWidget {
  const PasswordResetEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _emailSending(),
          const SizedBox(height: 30,),
          _sentEmail(),
          const SizedBox(height: 30,),
          _returnToLoginButton(context)
        ],
      ),
    );
  }
  Widget _emailSending() {
    return Center(
      child: SvgPicture.asset(
        AppVectors.emailSending
      ),
    );
  }

  Widget _sentEmail() {
    return const Center(
      child: Text(
        'Email z informacją jak zresetować hasło został wysłany.'
      ),
    );
  }

  Widget _returnToLoginButton(BuildContext context) {
    return BasicAppButton(
      onPressed: (){
        AppNavigator.pushReplacement(context, SignInPage());
      },
      width: 200,
      title: 'Wróć do strony logowania'
    );
  }
}
