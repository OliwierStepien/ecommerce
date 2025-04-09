import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/meal/usecases/get_meal_by_title.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/presentation/search/widgets/meal_found.dart';
import 'package:mealapp/presentation/search/widgets/meal_not_found.dart';
import 'package:mealapp/presentation/search/widgets/search_field.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocProvider(
        create: (context) =>
            MealsDisplayCubit(useCase: sl<GetMealByTitleUseCase>()),
        child: Scaffold(
          appBar: BasicAppbar(height: 80, title: SearchField()),
          body: BlocListener<VegetarianFilterCubit, bool>(
            listener: (context, isVegetarian) {
              final currentText =
                  context.read<MealsDisplayCubit>().state is MealsLoadingSuccess
                      ? (context.read<MealsDisplayCubit>().state
                              as MealsLoadingSuccess)
                          .meals
                          .firstOrNull
                          ?.title
                      : '';
              if (currentText!.isNotEmpty) {
                context.read<MealsDisplayCubit>().displayMeals(
                  params: {
                    'title': currentText,
                    'isVegetarian': isVegetarian,
                  },
                );
              }
            },
            child: BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
              builder: (context, state) {
                if (state is MealsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MealsLoadingSuccess) {
                  return state.meals.isEmpty
                      ? const MealNotFound()
                      : MealFound(meals: state.meals);
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
          ),
        ),
      ),
    );
  }
}
