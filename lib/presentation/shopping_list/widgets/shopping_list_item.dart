import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';

class ShoppingListItem extends StatelessWidget {
  final IngredientEntity? ingredient;
  final MealEntity? meal;
  final num? scaledAmount;

  const ShoppingListItem({
    super.key,
    required this.ingredient,
    required this.meal,
    required this.scaledAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomItem = ingredient != null && meal == null;

    return Card(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _buildIngredientText(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (meal?.title.trim().isNotEmpty ?? false)
                    Text(
                      context.l10n.fromMealTitle(meal!.title),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCustomItem)
                  IconButton(
                    onPressed: () => _editIngredient(context),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                IconButton(
                  onPressed: () => _removeIngredient(context),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildIngredientText(context) {
    if (ingredient == null) return context.l10n.customIngredient;

    final parts = <String>[
      ingredient!.ingredientName,
      if (scaledAmount != null)
        scaledAmount!.truncateToDouble() == scaledAmount
            ? scaledAmount!.toInt().toString()
            : scaledAmount!.toStringAsFixed(2),
      if (ingredient!.unit.isNotEmpty) ingredient!.unit,
    ];

    return parts.join(' ');
  }

  void _removeIngredient(BuildContext context) {
    if (ingredient != null && meal != null) {
      final mealCubit = context.read<ShoppingListMealIngredientCubit>();
      mealCubit.removeIngredient(
        ingredient!,
        meal!,
        suppressNotification: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n
                .removedIngredientFromShoppingList(ingredient!.ingredientName),
          ),
          action: SnackBarAction(
            label: context.l10n.undo,
            textColor: Colors.white,
            onPressed: () => mealCubit.restoreLastRemovedIngredient(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (ingredient != null) {
      final customCubit = context.read<ShoppingListCustomItemCubit>();
      customCubit.removeCustomIngredient(ingredient!.ingredientId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n
                .removedIngredientFromShoppingList(ingredient!.ingredientName),
          ),
          action: SnackBarAction(
            label: context.l10n.undo,
            textColor: Colors.white,
            onPressed: () => customCubit.restoreLastRemovedIngredient(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editIngredient(BuildContext context) async {
    if (ingredient == null) return;
    if (meal != null) return; // tylko custom item

    final controller = TextEditingController(text: ingredient!.ingredientName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edytuj"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nowa nazwa'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Zamknij"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text("Zapisz"),
          ),
        ],
      ),
    );

    final trimmed = newName?.trim() ?? '';
    if (trimmed.isEmpty) return;
    if (!context.mounted) return;

    final cubit = context.read<ShoppingListCustomItemCubit>();
    final state = cubit.state;

    // bierzemy aktualną kategorię z aktualnego stanu cubita
    if (state is! ShoppingListCustomItemLoaded) return;

    final existing = state.items.firstWhere(
      (x) => x.customItemId == ingredient!.ingredientId,
      orElse: () => ShoppingListCustomItemEntity(
        customItemId: ingredient!.ingredientId,
        customItemName: ingredient!.ingredientName,
        customItemCategory: '',
      ),
    );

    await cubit.updateCustomIngredient(
      ShoppingListCustomItemEntity(
        customItemId: existing.customItemId,
        customItemName: trimmed,
        customItemCategory: existing.customItemCategory, // ✅ bez zmian
      ),
      suppressNotification: true,
    );
  }
}
