import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_state.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/presentation/home/bloc/category_selection_cubit.dart';
import 'package:mealapp/routes/routes.dart';

class CategoriesRowView extends StatelessWidget {
  const CategoriesRowView({super.key});

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
          Text(
            context.l10n.categories,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: () {
              context.push(Routes.nestedAllCategoriesPage);
            },
            child: Text(
              context.l10n.seeAll,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
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
            child: BlocBuilder<CategorySelectionCubit, Set<String>>(
              builder: (context, selectedCategoryIds) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 15),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final isSelected =
                        selectedCategoryIds.contains(category.categoryId);

                    return GestureDetector(
                      onTap: () {
                        context
                            .read<CategorySelectionCubit>()
                            .toggleCategory(category.categoryId);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.transparent,
                                width: 3,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  ImageDisplayHelper.category(
                                    category.image,
                                    variant: ImgVariant.thumb,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            category.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: isSelected ? Colors.green : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
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

        return const SizedBox.shrink();
      },
    );
  }
}
