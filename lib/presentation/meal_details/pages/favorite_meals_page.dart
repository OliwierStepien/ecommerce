import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_grid.dart';

class FavoriteMealsPage extends StatelessWidget {
  const FavoriteMealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        title: Text('Ulubione posiłki'),
      ),
      body: BlocBuilder<FavoriteMealsCubit, MealsDisplayState>(
        builder: (context, state) {
          if (state is MealsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MealsLoadingSuccess) {
            return MealGrid(meals: state.meals);
          }
          if (state is MealsLoadingFailure) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                context.read<FavoriteMealsCubit>().displayFavoriteMeals();
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
