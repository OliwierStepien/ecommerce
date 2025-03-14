import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/presentation/auth/pages/signin.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/widgets/header.dart';
import 'package:mealapp/presentation/home/widgets/meals.dart';
import 'package:mealapp/presentation/home/widgets/search_field_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/categories.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => UserInfoDisplayCubit()..displayUserInfo()),
        BlocProvider(create: (context) => ButtonStateCubit()),
      ],
      child: Scaffold(
        body: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              final snackbar = SnackBar(
                content: Text(state.errorMessage),
                behavior: SnackBarBehavior.floating,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
            if (state is ButtonSuccessState) {
              const snackbar = SnackBar(
                content: Text('Zostałeś wylogowany'),
                behavior: SnackBarBehavior.floating,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              AppNavigator.pushAndRemove(context, SignInPage());
            }
          },
          child: const SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Header(), // 🔹 Header teraz tylko konsumuje stan
                SizedBox(height: 24),
                SearchFieldHome(),
                SizedBox(height: 24),
                Categories(),
                SizedBox(height: 24),
                Meals(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
