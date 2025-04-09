import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/routes/routes.dart';

import '../../category_meals/bloc/categories_display_state.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SeeAllCategories(),
        SizedBox(height: 20),
        _CategoriesList(),
      ],
    );
  }
}

class _SeeAllCategories extends StatelessWidget {
  const _SeeAllCategories();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Kategorie',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          GestureDetector(
            onTap: () {
              context.push(Routes.nestedAllCategoriesPage);
            },
            child: const Text(
              'Zobacz wszystkie',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesDisplayCubit, CategoriesDisplayState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoriesLoadingSuccess) {
          return SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    context.push(
                      Routes.nestedCategoryMealsPage,
                      extra: state.categories[index],
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              ImageDisplayHelper.generateCategoryImagePath(
                                  state.categories[index].image),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.categories[index].title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 15),
              itemCount: state.categories.length,
            ),
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
        return Container();
      },
    );
  }
}
