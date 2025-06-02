import 'package:flutter/material.dart';
import 'package:mealapp/extensions/context_extension.dart';

class ListByCategoriesHeader extends StatelessWidget {
  const ListByCategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.allCategories,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
    );
  }
}
