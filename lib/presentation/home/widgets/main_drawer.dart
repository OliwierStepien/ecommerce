import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _DrawerHeader(),
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
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings,
            color: AppColors.background,
            size: 38,
          ),
          const SizedBox(width: 10),
          Text(
            context.l10n.settings,
            style: GoogleFonts.playfairDisplay(
              color: AppColors.background,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
            color: isVegetarian ? AppColors.herb : AppColors.muted,
          ),
          title: Text(
            context.l10n.vegetarianMeals,
            style: TextStyle(
              color: isVegetarian ? AppColors.herb : AppColors.muted,
            ),
          ),
          trailing: Switch(
            value: isVegetarian,
            activeColor: AppColors.herb,
            onChanged: (_) {
              context.read<VegetarianFilterCubit>().toggle();
            },
          ),
        );
      },
    );
  }
}
