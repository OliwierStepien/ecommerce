import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SentEmail extends StatelessWidget {
  const SentEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.emailWithPasswordResetInstructionsHasBeenSent),
    );
  }
}