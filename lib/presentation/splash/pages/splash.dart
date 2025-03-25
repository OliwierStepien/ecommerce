import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/presentation/auth/pages/signin_login.dart';
import 'package:mealapp/presentation/home/pages/home.dart';
import 'package:mealapp/presentation/splash/bloc/splash_state.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          AppNavigator.pushReplacement(context, SignInLoginPage());
        }
        if (state is Authenticated) {
          AppNavigator.pushReplacement(context, const HomePage());
        }
      },
      child: Scaffold(
        body: Center(
          child: Image.asset(
            ImageDisplayHelper.generateSplashImagePath('splash'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
