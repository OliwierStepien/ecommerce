import 'package:flutter/material.dart';
import 'package:mealapp/presentation/auth/password_reset_email/widgets/email_sent_vector.dart';
import 'package:mealapp/presentation/auth/password_reset_email/widgets/return_to_login_button.dart';
import 'package:mealapp/presentation/auth/password_reset_email/widgets/sent_email_information.dart';

class PasswordResetEmailPage extends StatelessWidget {
  const PasswordResetEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmailSending(),
          SizedBox(
            height: 30,
          ),
          SentEmail(),
          SizedBox(
            height: 30,
          ),
          ReturnToLoginButton()
        ],
      ),
    );
  }
}