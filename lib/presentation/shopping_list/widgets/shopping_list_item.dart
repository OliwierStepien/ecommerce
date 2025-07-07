import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

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
    if (ingredient == null) {
      return context.l10n.customIngredient;
    }

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
    final shoppingListCubit = context.read<ShoppingListCubit>();

    if (ingredient != null && meal != null) {
      shoppingListCubit.removeIngredient(
        ingredient!,
        meal!,
        suppressNotification: true,
      );
    } else {
      shoppingListCubit.removeCustomIngredient(
        ingredient?.ingredientId ?? '',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.removedIngredientFromShoppingList(
            ingredient?.ingredientName ?? context.l10n.ingredients,
          ),
        ),
        action: SnackBarAction(
          label: context.l10n.undo,
          textColor: Colors.white,
          onPressed: () {
            shoppingListCubit.restoreLastRemovedIngredient();
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}