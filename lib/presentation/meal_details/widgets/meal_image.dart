import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/presentation/meal_details/widgets/favorite_button.dart';

class MealImage extends StatelessWidget {
  final MealEntity mealEntity;
  const MealImage({
    required this.mealEntity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.softFill,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  ImageDisplayHelper.meal(
                    mealEntity.image,
                    variant: ImgVariant.full,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageOverlayCircle(
                    child: IconButton(
                      padding: const EdgeInsets.all(7),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.ink,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  _ImageOverlayCircle(
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: FavoriteButton(mealEntity: mealEntity),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageOverlayCircle extends StatelessWidget {
  final Widget child;
  const _ImageOverlayCircle({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
