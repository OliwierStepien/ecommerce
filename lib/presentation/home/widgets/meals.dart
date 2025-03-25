import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/usecases/get_meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../service_locator.dart';

class Meals extends StatelessWidget {
  const Meals({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MealsDisplayCubit(useCase: sl<GetMealUseCase>())..displayMeals(),
      child: BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
        builder: (context, state) {
          if (state is MealsLoading) {
            return const CircularProgressIndicator();
          }
          if (state is MealsLoadingSuccess) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _title(),
                const SizedBox(
                  height: 20,
                ),
                _meals(state.meals)
              ],
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
          return Container();
        },
      ),
    );
  }

  Widget _title() {
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

  Widget _meals(List<MealEntity> meals) {
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
