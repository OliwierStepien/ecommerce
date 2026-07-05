import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/presentation/home/bloc/category_selection_cubit.dart';
import 'package:mealapp/presentation/home/bloc/meals_filter_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/service_locator.dart';

class MealsGridView extends StatelessWidget {
  const MealsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
      builder: (context, state) {
        if (state is MealsInitialState || state is MealsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MealsLoadingSuccess) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<MealsFilterCubit>(param1: state.meals),
              ),
            ],
            child: BlocListener<CategorySelectionCubit, Set<String>>(
              listener: (context, selectedIds) {
                context
                    .read<MealsFilterCubit>()
                    .filterByCategories(selectedIds);
              },
              child: BlocBuilder<MealsFilterCubit, List<MealEntity>>(
                builder: (context, filteredMeals) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MealSectionTitle(),
                      const SizedBox(height: 20),
                      _MealsList(meals: filteredMeals),
                    ],
                  );
                },
              ),
            ),
          );
        }

        if (state is MealsLoadingFailure) {
          return ErrorMessage(
            message: state.message,
            onRetry: () {
              context.read<MealsDisplayCubit>().displayMeals();
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _MealSectionTitle extends StatelessWidget {
  const _MealSectionTitle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealsFilterCubit, List<MealEntity>>(
      builder: (context, filteredMeals) {
        final count = filteredMeals.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                context.l10n.meals,
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '— $count',
                style: GoogleFonts.playfairDisplay(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              const _VegeToggle(),
            ],
          ),
        );
      },
    );
  }
}

class _VegeToggle extends StatelessWidget {
  const _VegeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VegetarianFilterCubit, bool>(
      builder: (context, isVegetarian) {
        return GestureDetector(
          onTap: () => context.read<VegetarianFilterCubit>().toggle(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.eco,
                size: 15,
                color: isVegetarian ? AppColors.herb : AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                'WEGE',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                  color: isVegetarian ? AppColors.herb : AppColors.muted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MealsList extends StatelessWidget {
  final List<MealEntity> meals;
  const _MealsList({required this.meals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          return MealCard(mealEntity: meals[index]);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
    );
  }
}
