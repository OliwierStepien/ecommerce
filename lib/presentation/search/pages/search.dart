import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/core/configs/assets/app_vectors.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/usecases/get_meal_by_title.dart';
import 'package:mealapp/presentation/search/widgets/search_field.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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
          body: BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
            builder: (context, state) {
              if (state is MealsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MealsLoadingSuccess) {
                return state.meals.isEmpty ? _notFound() : _meals(state.meals);
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
    );
  }
}

Widget _notFound() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgPicture.asset(
        AppVectors.notFound,
      ),
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Przepraszamy, nie znaleźliśmy żadnych pasujących wyników dla Twojego wyszukiwania.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      )
    ],
  );
}

Widget _meals(List<MealEntity> meals) {
  return GridView.builder(
    itemCount: meals.length,
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6),
    itemBuilder: (BuildContext context, int index) {
      return MealCard(mealEntity: meals[index]);
    },
  );
}
