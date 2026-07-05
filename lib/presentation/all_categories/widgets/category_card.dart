import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/routes/routes.dart';
import 'package:mealapp/common/helper/images/image_display.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;

  const CategoryCard({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          Routes.nestedCategoryMealsPage,
          extra: category,
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.softFill,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🖼️ Obraz kategorii
            CachedNetworkImage(
              imageUrl: ImageDisplayHelper.category(
                category.image,
                variant: ImgVariant.thumb,
              ),
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.softFill),
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.softFill),
            ),
            // Gradient od dołu
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0, 0.55],
                  colors: [
                    Color(0x9E33271E),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // 📌 Tytuł kategorii
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                category.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.background,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
