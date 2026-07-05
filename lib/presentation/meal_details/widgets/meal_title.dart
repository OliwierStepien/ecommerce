import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:flutter/material.dart';

class MealTitle extends StatelessWidget {
  final MealEntity mealEntity;
  const MealTitle({
    required this.mealEntity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('DANIE GŁÓWNE'),
          const SizedBox(height: 4),
          Text(
            mealEntity.title,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w600,
              fontSize: 25,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
