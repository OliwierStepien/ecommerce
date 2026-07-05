import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninPasswordHeader extends StatelessWidget {
  final String? email;
  const SigninPasswordHeader({this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          kicker: 'OSTATNI KROK',
          title: context.l10n.signIn,
          titleSize: 32,
        ),
        if (email != null) ...[
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              children: [
                const TextSpan(text: 'Zalogowano jako '),
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
