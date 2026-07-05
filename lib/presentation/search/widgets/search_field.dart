import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_title.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MealsDisplayCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: cubit.controller,
        focusNode: cubit.focusNode,
        cursorColor: AppColors.accent,
        onChanged: (value) {
          final isVegetarian = context.read<VegetarianFilterCubit>().state;
          if (value.isEmpty) {
            cubit.displayInitial();
          } else {
            cubit.displayMeals(
              params: GetMealByTitleParams(
                title: value,
                isVegetarian: isVegetarian,
              ),
            );
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.accent),
          hintText: context.l10n.search,
        ),
      ),
    );
  }
}
