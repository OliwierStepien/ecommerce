import 'package:flutter/material.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/extensions/context_extension.dart';

class ListByCategoriesHeader extends StatelessWidget {
  const ListByCategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      kicker: 'PRZEGLĄDAJ',
      title: context.l10n.allCategories,
      titleSize: 22,
    );
  }
}
