import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
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
  final bool isChecked;

  const ShoppingListItem({
    super.key,
    required this.ingredient,
    required this.meal,
    required this.scaledAmount,
    this.isChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomItem = ingredient != null && meal == null;

    return InkWell(
      onTap: () => _toggleChecked(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.dividerLight),
          ),
        ),
        child: Row(
          children: [
            Semantics(
              label: isChecked
                  ? context.l10n.markAsNotPurchased
                  : context.l10n.markAsPurchased,
              button: true,
              child: IconButton(
                onPressed: () => _toggleChecked(context),
                icon: Icon(
                  isChecked
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      isChecked ? AppColors.herb : const Color(0xFFCDBFA8),
                ),
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: isChecked ? 0.45 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                        ),
                        children: [
                          TextSpan(text: _ingredientName(context)),
                          if (_amountText.isNotEmpty)
                            TextSpan(
                              text: ' · $_amountText',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (meal?.title.trim().isNotEmpty ?? false)
                      Text(
                        context.l10n.fromMealTitle(meal!.title),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCustomItem)
                  IconButton(
                    onPressed: () => _editIngredient(context),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.muted),
                  ),
                IconButton(
                  onPressed: () => _removeIngredient(context),
                  icon: const Icon(Icons.delete, color: AppColors.danger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _ingredientName(BuildContext context) {
    if (ingredient == null) return 'Własny składnik';
    return ingredient!.ingredientName;
  }

  String get _amountText {
    if (ingredient == null) return '';
    final parts = <String>[
      if (scaledAmount != null)
        scaledAmount!.truncateToDouble() == scaledAmount
            ? scaledAmount!.toInt().toString()
            : scaledAmount!.toStringAsFixed(2),
      if (ingredient!.unit.isNotEmpty) ingredient!.unit,
    ];
    return parts.join(' ');
  }

  void _toggleChecked(BuildContext context) {
    if (ingredient == null) return;

    if (meal != null) {
      context
          .read<ShoppingListMealIngredientCubit>()
          .toggleIngredientChecked(ingredient!, meal!);
    } else {
      context
          .read<ShoppingListCustomItemCubit>()
          .toggleCustomItemChecked(ingredient!.ingredientId);
    }
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

    // copyWith zachowuje kategorię, metadane źródła i stan odhaczenia
    await cubit.updateCustomIngredient(
      existing.copyWith(customItemName: trimmed),
      suppressNotification: true,
    );
  }
}
