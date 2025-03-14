import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/common/widgets/meal/meal_card.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/usecases/get_meal_by_category_id.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryMealsPage extends StatelessWidget {
  final CategoryEntity categoryEntity;
  const CategoryMealsPage({
    super.key,
    required this.categoryEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: BlocProvider(
          create: (context) =>
              MealsDisplayCubit(useCase: sl<GetMealByCategoryIdUseCase>())
                ..displayMeals(params: categoryEntity.categoryId),
          child: BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
            builder: (context, state) {
              if (state is MealsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MealsLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _categoryInfo(state.meals),
                      const SizedBox(
                        height: 10,
                      ),
                      _meals(state.meals)
                    ],
                  ),
                );
              }
              return Container();
            },
          )),
    );
  }

  Widget _categoryInfo(List<MealEntity> meals) {
    return Text(
      '${categoryEntity.title} (${meals.length})',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _meals(List<MealEntity> meals) {
    return Expanded(
      child: GridView.builder(
        itemCount: meals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.6),
        itemBuilder: (BuildContext context, int index) {
          return MealCard(mealEntity: meals[index]);
        },
      ),
    );
  }
}
