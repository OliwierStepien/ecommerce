import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/all_categories/widgets/old_category_item.dart';
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
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return CategoryItem(category: category);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: state.categories.length,
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