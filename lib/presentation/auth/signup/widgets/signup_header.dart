import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      kicker: 'DOŁĄCZ DO NAS',
      title: context.l10n.createAccount,
      titleSize: 31,
    );
  }
}
