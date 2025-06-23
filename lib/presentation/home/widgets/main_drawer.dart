import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/domain/auth/usecase/signout.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/service_locator.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _DrawerHeader(),
          _SignOutTile(),
          _VegetarianSwitch(),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings,
            color: Colors.white,
            size: 50,
          ),
          const SizedBox(width: 10),
          Text(
            context.l10n.settings,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: Text(context.l10n.signOut),
      onTap: () {
        context.read<ButtonStateCubit>().execute(usecase: sl<SignoutUsecase>());
      },
    );
  }
}

class _VegetarianSwitch extends StatelessWidget {
  const _VegetarianSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VegetarianFilterCubit, bool>(
      builder: (context, isVegetarian) {
        return ListTile(
          leading: Icon(
            Icons.eco,
            color: isVegetarian ? Colors.green : Colors.grey,
          ),
          title: Text(
            context.l10n.vegetarianMeals,
            style: TextStyle(
              color: isVegetarian ? Colors.green : Colors.grey,
            ),
          ),
          trailing: Switch(
            value: isVegetarian,
            onChanged: (_) {
              context.read<VegetarianFilterCubit>().toggle();
            },
          ),
        );
      },
    );
  }
}