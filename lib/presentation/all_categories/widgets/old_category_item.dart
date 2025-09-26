import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/helper/images/image_display.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/routes/routes.dart';

class CategoryItem extends StatelessWidget {
  final CategoryEntity category;

  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.nestedCategoryMealsPage, extra: category);
      },
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    ImageDisplayHelper.generateCategoryImagePath(category.image),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              category.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }
}