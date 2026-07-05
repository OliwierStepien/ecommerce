import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class MealStep extends StatelessWidget {
  final MealEntity mealEntity;
  const MealStep({
    super.key,
    required this.mealEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              context.l10n.cookingSteps,
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          ...mealEntity.steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${entry.key + 1}.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: const Color(0xFF5C5245),
                            height: 1.5,
                          ),
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
