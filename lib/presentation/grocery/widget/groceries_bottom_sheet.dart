import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/grocery/bloc/groceries_display_cubit.dart';
import 'package:mealapp/presentation/grocery/bloc/groceries_display_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';

class GroceriesBottomSheet extends StatelessWidget {
  const GroceriesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Groceries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          BlocBuilder<GroceriesDisplayCubit, GroceriesDisplayState>(
            builder: (context, state) {
              if (state is GroceriesLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              if (state is GroceriesLoadingFailure) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (state is GroceriesLoadingSuccess) {
                final grouped = _groupByCategory(state.groceries);

                return Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: grouped.entries.map((entry) {
                      final category = entry.key;
                      final items = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          ...items.map((g) => _GroceryTile(grocery: g)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Map<String, List<GroceryEntity>> _groupByCategory(List<GroceryEntity> items) {
    final map = <String, List<GroceryEntity>>{};
    for (final g in items) {
      final cat = g.groceryItemCategory.trim().isEmpty ? 'Inne' : g.groceryItemCategory;
      map.putIfAbsent(cat, () => []).add(g);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }
}

class _GroceryTile extends StatelessWidget {
  final GroceryEntity grocery;
  const _GroceryTile({required this.grocery});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(grocery.groceryItemName),
      subtitle: Text(grocery.groceryItemCategory),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () {
          final customCubit = context.read<ShoppingListCustomItemCubit>();

          customCubit.addCustomIngredient(
            ShoppingListCustomItemEntity(
              customItemId: grocery.groceryItemId,
              customItemName: grocery.groceryItemName,
              customItemCategory: grocery.groceryItemCategory,
            ),
            suppressNotification: true,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.addedIngredientToShoppingList(grocery.groceryItemName),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}