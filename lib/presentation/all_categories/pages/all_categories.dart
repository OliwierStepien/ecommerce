import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_state.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/routes/routes.dart';

import '../../../common/helper/images/image_display.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(hideBack: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _listByCategories(),
            const SizedBox(height: 10),
            Expanded(child: _categories()),
          ],
        ),
      ),
    );
  }
}

Widget _listByCategories() {
  return const Text(
    'Wszystkie kategorie',
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
  );
}

Widget _categories() {
  return BlocBuilder<CategoriesDisplayCubit, CategoriesDisplayState>(
    builder: (context, state) {
      if (state is CategoriesLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is CategoriesLoadingSuccess) {
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.push(Routes.nestedCategoryMealsPage,
                    extra: state.categories[index]);
              },
              child: Container(
                height: 70,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            ImageDisplayHelper.generateCategoryImagePath(
                                state.categories[index].image),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      state.categories[index].title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
            );
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
      return Container();
    },
  );
}
