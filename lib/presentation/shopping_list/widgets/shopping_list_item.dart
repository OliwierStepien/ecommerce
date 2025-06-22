import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class ShoppingListItem extends StatelessWidget {
  final String ingredientId;
  final String ingredientName;
  final num? amountPerPortion;
  final num? scaledAmount;
  final String unit;
  final String title;
  final MealEntity? mealEntity;
  final String ingredientCategory;

  const ShoppingListItem({
    super.key,
    required this.ingredientId,
    required this.ingredientName,
    required this.amountPerPortion,
    this.scaledAmount,
    required this.unit,
    required this.title,
    required this.mealEntity,
    required this.ingredientCategory,
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
                    _buildIngredientText(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (title.trim().isNotEmpty)
                    Text(
                      context.l10n.fromMealTitle(title),
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

  String _buildIngredientText() {
    // Dla customowych składników (gdzie mealEntity == null) pokazuj tylko nazwę
    if (mealEntity == null) {
      return ingredientName;
    }
    
    // Dla składników z przepisów pokazuj pełne informacje
  return [
    ingredientName,
    if (scaledAmount != null) 
      scaledAmount?.toStringAsFixed(scaledAmount?.truncateToDouble() == scaledAmount ? 0 : 2),
    if (unit.isNotEmpty) unit,
  ].join(' ');
}

  void _removeIngredient(BuildContext context) {
    final shoppingListCubit = context.read<ShoppingListCubit>();

    if (mealEntity != null) {
      shoppingListCubit.addOrRemoveIngredient(
        IngredientEntity(
          ingredientId: ingredientId,
          ingredientName: ingredientName,
          amountPerPortion: amountPerPortion,
          unit: unit,
          ingredientCategory: ingredientCategory,
          mealId: mealEntity!.mealId,
        ),
        mealEntity!,
        suppressNotification: true,
      );
    } else {
      shoppingListCubit.removeCustomIngredient(ingredientId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.removedIngredientFromShoppingList(ingredientName),
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