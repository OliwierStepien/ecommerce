import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/routes/routes.dart';
import 'package:mealapp/common/helper/images/image_display.dart';

class MealListItem extends StatelessWidget {
  final MealEntity mealEntity;
  final VoidCallback? onRemove;

  const MealListItem({
    super.key,
    required this.mealEntity,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.nestedMealDetailPage, extra: mealEntity);
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // miniatura posiłku
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                ImageDisplayHelper.generateMealImagePath(mealEntity.image),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),

            // tytuł
            Expanded(
              child: Text(
                mealEntity.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}