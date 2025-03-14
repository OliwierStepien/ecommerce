import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/common/helper/navigator/app_navigator.dart';
import 'package:mealapp/presentation/all_categories/pages/all_categories.dart';
import 'package:mealapp/presentation/category_meals/pages/category_meals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../category_meals/bloc/categories_display_state.dart';
import '../../../domain/category/entity/category.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesDisplayCubit()..displayCategories(),
      child: BlocBuilder<CategoriesDisplayCubit, CategoriesDisplayState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const CircularProgressIndicator();
          }
          if (state is CategoriesLoaded) {
            return Column(
              children: [
                _seaAll(context),
                const SizedBox(
                  height: 20,
                ),
                _categories(state.categories)
              ],
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _seaAll(BuildContext context) {
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
              AppNavigator.push(context, const AllCategoriesPage());
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

  Widget _categories(List<CategoryEntity> categories) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              AppNavigator.push(
                context,
                CategoryMealsPage(categoryEntity: categories[index]),
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
                            categories[index].image),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  categories[index].title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 14),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: categories.length,
      ),
    );
  }
}
