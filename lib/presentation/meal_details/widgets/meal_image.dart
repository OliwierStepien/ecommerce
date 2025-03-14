import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:flutter/material.dart';

class MealImage extends StatelessWidget {
  final MealEntity mealEntity;
  const MealImage
({
    required this.mealEntity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              ImageDisplayHelper.generateMealImagePath(mealEntity.image),
            ),
          ),
        ),
      ),
    );
  }
}
