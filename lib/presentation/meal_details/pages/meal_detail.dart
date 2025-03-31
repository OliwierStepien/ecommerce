import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/meal_details/widgets/favorite_button.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_image.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_ingredient.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_step.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_title.dart';
import 'package:flutter/material.dart';

class MealDetailPage extends StatelessWidget {
  final MealEntity mealEntity;
  const MealDetailPage({super.key, required this.mealEntity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        hideBack: false,
        action: FavoriteButton(mealEntity: mealEntity),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MealImage(mealEntity: mealEntity),
            const SizedBox(height: 10),
            MealTitle(mealEntity: mealEntity),
            Align(
              alignment: Alignment.centerLeft,
              child: MealIngredient(mealEntity: mealEntity),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: MealStep(mealEntity: mealEntity),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}