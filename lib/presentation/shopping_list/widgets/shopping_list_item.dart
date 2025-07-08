import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
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
            IconButton(
              onPressed: () => _removeIngredient(context),
              icon: const Icon(Icons.delete),
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
            context.l10n.removedIngredientFromShoppingList(
              ingredient!.ingredientName),
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
            context.l10n.removedIngredientFromShoppingList(
              ingredient!.ingredientName),
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
}