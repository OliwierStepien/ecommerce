import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/presentation/meal_details/widgets/favorite_button.dart';
import 'package:mealapp/routes/routes.dart';
import '../../helper/images/image_display.dart';

class MealCard extends StatelessWidget {
  final MealEntity mealEntity;
  const MealCard({
    required this.mealEntity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final meta = [
      '${mealEntity.portion} PORCJE',
      if (mealEntity.isVegetarian) 'WEGE',
    ].join(' · ');

    return GestureDetector(
      onTap: () {
        context.push(
          Routes.nestedMealDetailPage,
          extra: mealEntity,
        );
      },
      child: Container(
        width: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: ImageDisplayHelper.meal(
                      mealEntity.image,
                      variant: ImgVariant.thumb,
                    ),
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.softFill),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.softFill),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: FavoriteButton(mealEntity: mealEntity),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 38,
                    child: Text(
                      mealEntity.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
          ],
        ),
      ),
    );
  }
}
