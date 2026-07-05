import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';

/// Mała etykieta wersalikami nad tytułem („kicker").
class Kicker extends StatelessWidget {
  final String text;
  final Color color;

  const Kicker(this.text, {this.color = AppColors.accent, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.8,
        color: color,
      ),
    );
  }
}

/// Nagłówek strony: kicker wersalikami + tytuł serifem (Playfair Display).
class PageHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final double titleSize;
  final CrossAxisAlignment alignment;

  const PageHeader({
    required this.kicker,
    required this.title,
    this.titleSize = 24,
    this.alignment = CrossAxisAlignment.start,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Kicker(kicker),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

/// Nagłówek sekcji na złotej linii: tytuł serifem po lewej,
/// opcjonalna akcja (np. kicker-link) po prawej.
class SectionHeader extends StatelessWidget {
  final String title;
  final double titleSize;
  final Widget? trailing;

  const SectionHeader({
    required this.title,
    this.titleSize = 17,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.accent)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
