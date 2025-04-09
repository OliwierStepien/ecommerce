import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/category_meals/widgets/category_info.dart';
import 'package:mealapp/presentation/category_meals/widgets/meals_grid_view.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/domain/meal/usecases/get_meal_by_category_id.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
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
      body: BlocBuilder<VegetarianFilterCubit, bool>(
        builder: (context, isVegetarian) {
          return BlocProvider(
            create: (context) =>
                MealsDisplayCubit(useCase: sl<GetMealByCategoryIdUseCase>())
                  ..displayMeals(params: {
                    'categoryId': categoryEntity.categoryId,
                    'isVegetarian': isVegetarian,
                  }),
            child: BlocBuilder<MealsDisplayCubit, MealsDisplayState>(
              builder: (context, state) {
                if (state is MealsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MealsLoadingSuccess) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryInfo(
                            categoryEntity: categoryEntity, meals: state.meals),
                        const SizedBox(height: 10),
                        MealsGridView(meals: state.meals),
                      ],
                    ),
                  );
                }
                if (state is MealsLoadingFailure) {
                  return ErrorMessage(
                    message: state.message,
                    onRetry: () {
                      context.read<MealsDisplayCubit>().displayMeals(params: {
                        'categoryId': categoryEntity.categoryId,
                        'isVegetarian':
                            context.read<VegetarianFilterCubit>().state,
                      });
                    },
                  );
                }
                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}
