import 'package:go_router/go_router.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/home/widgets/header.dart';
import 'package:mealapp/presentation/home/widgets/main_drawer.dart';
import 'package:mealapp/presentation/home/widgets/meals.dart';
import 'package:mealapp/presentation/home/widgets/search_field_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/routes/routes.dart';

import '../widgets/categories.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserInfoDisplayCubit()..displayUserInfo(),
          ),
        ],
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
              context.go(Routes.signInEmailPage);
            }
          },
          child: const SingleChildScrollView(
            child: 
            Column(
              children: [
                SizedBox(height: 50),
                Header(),
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
