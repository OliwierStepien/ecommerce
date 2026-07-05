import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/routes/routes.dart';

class SearchFieldHome extends StatelessWidget {
  const SearchFieldHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        readOnly: true,
        onTap: () {
          context.push(Routes.nestedSearchPage);
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.muted),
          hintText: 'Szukaj dania…',
        ),
      ),
    );
  }
}
