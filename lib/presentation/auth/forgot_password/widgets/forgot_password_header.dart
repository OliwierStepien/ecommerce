import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          kicker: 'BEZ OBAW',
          title: context.l10n.resetPassword,
          titleSize: 30,
        ),
        const SizedBox(height: 10),
        Text(
          'Podaj swój adres e-mail, a wyślemy Ci instrukcję resetu hasła.',
          style: GoogleFonts.playfairDisplay(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
