import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SigninEmailHeader extends StatelessWidget {
  const SigninEmailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      kicker: 'WITAJ PONOWNIE',
      title: context.l10n.signIn,
      titleSize: 32,
    );
  }
}
