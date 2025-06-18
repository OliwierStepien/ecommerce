import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class ShoppingListItem extends StatelessWidget {
  final String ingredient;
  final String title;
  final MealEntity? mealEntity;

  const ShoppingListItem({
    super.key,
    required this.ingredient,
    required this.title,
    required this.mealEntity,
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
                    ingredient,
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
onPressed: () {
  final shoppingListCubit = context.read<ShoppingListCubit>();

  if (mealEntity != null) {
    shoppingListCubit.addOrRemoveIngredient(
      ingredient,
      mealEntity!,
      suppressNotification: true,
    );
  } else {
    shoppingListCubit.removeCustomIngredient(ingredient);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        context.l10n.removedIngredientFromShoppingList(ingredient),
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
},
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
