import 'package:go_router/go_router.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/presentation/splash/bloc/splash_state.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/routes/routes.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          context.go(Routes.signInEmailPage);
        } else if (state is Authenticated) {
          context.go(Routes.homePage);
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