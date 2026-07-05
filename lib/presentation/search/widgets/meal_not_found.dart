import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';

class MealNotFound extends StatelessWidget {
  const MealNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.restaurant,
          size: 56,
          color: Color(0xFFC6B8A2),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.sorryWeCouldNotFindAnyMatchingResultsForYourSearch,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: AppColors.muted,
            ),
          ),
        )
      ],
    );
  }
}
