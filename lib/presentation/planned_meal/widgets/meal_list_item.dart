// presentation/planned_meal/widgets/meal_list_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/routes/routes.dart';
import 'package:mealapp/common/helper/images/image_display.dart';

class MealListItem extends StatelessWidget {
  final MealEntity mealEntity;
  final VoidCallback? onRemove;
  final Widget? dragHandle; // 👈 Uchwyt do przeciągania

  const MealListItem({
    super.key,
    required this.mealEntity,
    this.onRemove,
    this.dragHandle, // 👈 Opcjonalny uchwyt
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.nestedMealDetailPage, extra: mealEntity);
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // miniatura posiłku
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: ImageDisplayHelper.meal(
                  mealEntity.image,
                  variant: ImgVariant.thumb,
                ),
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  width: 46,
                  height: 46,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // tytuł
            Expanded(
              child: Text(
                mealEntity.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFFB3A58F),
                ),
                onPressed: onRemove,
              ),

            // 👇 Uchwyt do przeciągania (jeśli przekazany)
            if (dragHandle != null) dragHandle!,
          ],
        ),
      ),
    );
  }
}
