import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/all_categories/widgets/category_card.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_state.dart';

class ListByCategories extends StatelessWidget {
  const ListByCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesDisplayCubit, CategoriesDisplayState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoriesLoadingSuccess) {
          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: state.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return CategoryCard(category: category);
            },
          );
        }
        if (state is CategoriesLoadingFailure) {
          return ErrorMessage(
            message: state.message,
            onRetry: () {
              context.read<CategoriesDisplayCubit>().displayCategories();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}