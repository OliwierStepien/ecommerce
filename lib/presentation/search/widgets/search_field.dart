import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        onChanged: (value) {
          final isVegetarian = context.read<VegetarianFilterCubit>().state;
          if (value.isEmpty) {
            cubit.displayInitial();
          } else {
            cubit.displayMeals(
              params: {
                'title': value,
                'isVegetarian': isVegetarian,
              },
            );
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          prefixIcon: SvgPicture.asset(
            AppVectors.search,
            fit: BoxFit.none,
          ),
          hintText: context.l10n.search,
          hintStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
