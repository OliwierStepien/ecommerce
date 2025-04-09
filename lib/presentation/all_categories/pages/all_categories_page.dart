import 'package:mealapp/presentation/all_categories/widgets/list_by_categories.dart';
import 'package:mealapp/presentation/all_categories/widgets/list_by_categories_header.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:flutter/material.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BasicAppbar(hideBack: false),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListByCategoriesHeader(),
            SizedBox(height: 10),
            Expanded(child: ListByCategories()),
          ],
        ),
      ),
    );
  }
}
