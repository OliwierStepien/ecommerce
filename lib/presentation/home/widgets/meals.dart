import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';

class Meals extends StatelessWidget {
  const Meals({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
      builder: (context, state) {
        if (state is MealsInitialState || state is MealsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MealsLoadingSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MealSectionTitle(),
              const SizedBox(height: 20),
              _MealsList(meals: state.meals),
            ],
          );
        }
        if (state is MealsLoadingFailure) {
          return ErrorMessage(
            message: state.message,
            onRetry: () {
              context.read<MealsDisplayCubit>().displayMeals(
                params: context.read<VegetarianFilterCubit>().state,
              );
            },
          );
        }
        return Container();
      },
    );
  }
}

class _MealSectionTitle extends StatelessWidget {
  const _MealSectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Text(
        'Dania',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return MealCard(
              mealEntity: meals[index],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
          itemCount: meals.length),
    );
  }
}