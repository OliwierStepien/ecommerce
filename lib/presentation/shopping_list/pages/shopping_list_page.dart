import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';
import 'package:mealapp/presentation/shopping_list/widgets/shopping_list_item.dart';
import 'package:mealapp/presentation/shopping_list/widgets/add_custom_ingredient_bottom_sheet.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  void _showAddIngredientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddCustomIngredientBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Text(context.l10n.shoppingList),
        hideBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ShoppingListCubit, List<Map<String, dynamic>>>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.length,
                    itemBuilder: (context, index) {
                      final item = state[index];
                      final ingredient = item['ingredient']!;
                      final title = item['title'] ?? '';
                      final mealEntity = item['mealEntity'] as MealEntity?;

                      return ShoppingListItem(
                        ingredient: ingredient,
                        title: title,
                        mealEntity: mealEntity,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                mini: true, // <- Mały FAB
                onPressed: () => _showAddIngredientSheet(context),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}