import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/domain/auth/usecases/signout.dart';
import 'package:mealapp/routes/routes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
                height: 140,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Ustawienia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                )),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Wyloguj się'),
              onTap: () {
                context.read<ButtonStateCubit>().execute(usecase: SignoutUsecase());
              },
            ),
          ],
        ),
      ),
    );
  }
}