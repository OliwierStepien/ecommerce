import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/grocery/bloc/groceries_display_cubit.dart';
import 'package:mealapp/presentation/grocery/bloc/groceries_display_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_state.dart';

class GroceriesBottomSheet extends StatelessWidget {
  const GroceriesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Łatwo sterujesz rozmiarem w 1 miejscu
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        );

    final categoryStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        );

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
            'Przykładowa lista zakupów',
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
                          const SizedBox(height: 10),
                          Text(category, style: categoryStyle),
                          const SizedBox(height: 8),
                          ...items.map(
                            (g) => _GroceryTile(
                              grocery: g,
                              titleStyle: titleStyle,
                              subtitleStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 14),
                            ),
                          ),
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
      final cat =
          g.groceryItemCategory.trim().isEmpty ? 'Inne' : g.groceryItemCategory;
      map.putIfAbsent(cat, () => []).add(g);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }
}

class _GroceryTile extends StatelessWidget {
  final GroceryEntity grocery;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const _GroceryTile({
    required this.grocery,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingListCustomItemCubit, ShoppingListCustomItemState>(
      builder: (context, customState) {
        final bool isAdded = customState is ShoppingListCustomItemLoaded &&
            customState.items.any((x) => x.customItemId == grocery.groceryItemId);

        return ListTile(
          dense: false, // ✅ pozwala na większą wysokość wiersza
          visualDensity: VisualDensity.standard,
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 10, // ✅ większe “oddechy”
          title: Text(
            grocery.groceryItemName,
            style: titleStyle ??
                Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
          ),
          subtitle: Text(
            grocery.groceryItemCategory,
            style: subtitleStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          trailing: IconButton(
            icon: Icon(
              isAdded ? Icons.check_circle : Icons.add_circle_outline,
              color: isAdded ? Colors.green : null,
              size: 26, // ✅ opcjonalnie większa ikonka
            ),
            onPressed: () async {
              final customCubit = context.read<ShoppingListCustomItemCubit>();

              // ✅ Toggle OFF (usuń)
              if (isAdded) {
                customCubit.removeCustomIngredient(
                  grocery.groceryItemId,
                  suppressNotification: true,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.removedIngredientFromShoppingList(
                        grocery.groceryItemName,
                      ),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
                return;
              }

              // ✅ Toggle ON (dodaj) — najpierw dialog edycji nazwy
              final editedName = await _showEditNameDialog(
                context: context,
                initial: grocery.groceryItemName,
              );

              final trimmed = editedName?.trim() ?? '';
              if (trimmed.isEmpty) return;
              if (!context.mounted) return;

              // ✅ Deduplikacja na wszelki wypadek (gdyby stan się zmienił)
              final state = customCubit.state;
              final alreadyAdded = state is ShoppingListCustomItemLoaded &&
                  state.items.any((x) => x.customItemId == grocery.groceryItemId);
              if (alreadyAdded) return;

              customCubit.addCustomIngredient(
                ShoppingListCustomItemEntity(
                  customItemId: grocery.groceryItemId, // 🔑 stałe ID = brak duplikatów
                  customItemName: trimmed, // ✅ nazwa po edycji
                  customItemCategory: grocery.groceryItemCategory,
                ),
                suppressNotification: true,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.addedIngredientToShoppingList(trimmed),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _showEditNameDialog({
    required BuildContext context,
    required String initial,
  }) async {
    final controller = TextEditingController(text: initial);

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dodaj do listy'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Np. banany 5kg',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(dialogContext).pop(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }
}