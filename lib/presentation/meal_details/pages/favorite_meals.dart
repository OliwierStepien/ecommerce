import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteMealsPage extends StatelessWidget {
  const FavoriteMealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        title: Text('Ulubione posiłki'),
      ),
      body: BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
        builder: (context, state) {
          if (state is MealsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MealsLoadingSuccess) {
            return _products(state.meals);
          }
          if (state is MealsLoadingFailure) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                context.read<MealsDisplayCubit>().displayMeals();
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _products(List<MealEntity> meals) {
    return GridView.builder(
      itemCount: meals.length,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (BuildContext context, int index) {
        return MealCard(mealEntity: meals[index]);
      },
    );
  }
}
