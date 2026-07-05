import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/presentation/meal_details/widgets/favorite_button.dart';
import 'package:mealapp/routes/routes.dart';

class MealFound extends StatelessWidget {
  final List<MealEntity> meals;
  const MealFound({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length + 1,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.dividerLight),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Kicker('${meals.length} WYNIKI', color: AppColors.muted),
          );
        }
        return _SearchResultRow(mealEntity: meals[index - 1]);
      },
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  final MealEntity mealEntity;
  const _SearchResultRow({required this.mealEntity});

  @override
  Widget build(BuildContext context) {
    final meta = [
      '${mealEntity.portion} PORCJE',
      if (mealEntity.isVegetarian) 'WEGE',
    ].join(' · ');

    return InkWell(
      onTap: () {
        context.push(Routes.nestedMealDetailPage, extra: mealEntity);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: ImageDisplayHelper.meal(
                  mealEntity.image,
                  variant: ImgVariant.thumb,
                ),
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 58,
                  height: 58,
                  color: AppColors.softFill,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 58,
                  height: 58,
                  color: AppColors.softFill,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.muted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealEntity.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            FavoriteButton(mealEntity: mealEntity),
          ],
        ),
      ),
    );
  }
}
