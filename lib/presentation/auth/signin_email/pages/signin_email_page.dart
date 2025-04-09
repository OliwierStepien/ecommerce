import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/presentation/auth/signin_email/widgets/continue_email_button.dart';
import 'package:mealapp/presentation/auth/signin_email/widgets/create_account_text.dart';
import 'package:mealapp/presentation/auth/signin_email/widgets/signin_email_field.dart';
import 'package:mealapp/presentation/auth/signin_email/widgets/signin_email_header.dart';

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
                const SigninEmailHeader(),
                const SizedBox(height: 20),
                SigninEmailField(controller: _emailCon,),
                const SizedBox(height: 20),
                ContinueEmailButton(
                  controller: _emailCon,
                  formKey: _formKey,
                ),
                const SizedBox(height: 20),
                const CreateAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}