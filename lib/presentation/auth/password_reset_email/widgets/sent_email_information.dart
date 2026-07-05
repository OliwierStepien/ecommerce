import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SentEmail extends StatelessWidget {
  const SentEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Sprawdź skrzynkę',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            context.l10n.emailWithPasswordResetInstructionsHasBeenSent,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
