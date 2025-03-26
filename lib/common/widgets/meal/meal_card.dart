import 'package:go_router/go_router.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/routes/routes.dart';

import '../../../core/configs/theme/app_colors.dart';
import '../../helper/images/image_display.dart';

class MealCard extends StatelessWidget {
  final MealEntity mealEntity;
  const MealCard({
    required this.mealEntity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          Routes.nestedMealDetailPage,
          extra: mealEntity,
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      ImageDisplayHelper.generateMealImagePath(
                        mealEntity.image,
                      ),
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    mealEntity.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
