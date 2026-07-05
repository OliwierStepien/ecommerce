import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
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
      child: SectionHeader(
        title: context.l10n.categories,
        titleSize: 16,
        trailing: GestureDetector(
          onTap: () {
            context.push(Routes.nestedAllCategoriesPage);
          },
          child: Kicker(context.l10n.seeAll),
        ),
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
                          _CategoryCircle(
                            imageUrl: ImageDisplayHelper.category(
                              category.image,
                              variant: ImgVariant.thumb,
                            ),
                            isSelected: isSelected,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.title,
                            style: GoogleFonts.dmSans(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 10.5,
                              color:
                                  isSelected ? AppColors.ink : AppColors.muted,
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

class _CategoryCircle extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;

  const _CategoryCircle({required this.imageUrl, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final image = Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.softFill,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(imageUrl),
        ),
      ),
    );

    if (!isSelected) return image;

    // Pierścień accent z zewnętrzną obwódką hairline i przerwą tła
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 2),
        ),
        child: image,
      ),
    );
  }
}
