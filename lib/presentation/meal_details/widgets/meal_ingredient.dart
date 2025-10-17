import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/portion_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_state.dart';

class MealIngredient extends StatelessWidget {
  final MealEntity mealEntity;
  final int currentPortion;

  const MealIngredient({
    super.key,
    required this.mealEntity,
    required this.currentPortion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.ingredients,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      context.l10n.addToShoppingList,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.shopping_cart, color: Colors.green.shade700),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: mealEntity.ingredients.map((ingredient) {
              final baseAmount = ingredient.amountPerPortion?.toDouble() ?? 0;
              return Column(
                children: [
                  _buildIngredientItem(context, ingredient, baseAmount),
                  const Divider(height: 10, thickness: 0.5),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(
      BuildContext context, IngredientEntity ingredient, double baseAmount) {
    return BlocListener<ShoppingListMealIngredientCubit,
        ShoppingListMealIngredientState>(
      listenWhen: (previous, current) {
        if (previous is! ShoppingListMealIngredientLoaded ||
            current is! ShoppingListMealIngredientLoaded) {
          return false;
        }

        final portionCubit = context.read<PortionCubit>();
        final prevItems = previous.items;
        final currItems = current.items;

        final wasAdded = prevItems.any(
          (item) =>
              item['ingredientId'] == ingredient.ingredientId &&
              item['mealId'] == portionCubit.meal.mealId,
        );

        final isNowAdded = currItems.any(
          (item) =>
              item['ingredientId'] == ingredient.ingredientId &&
              item['mealId'] == portionCubit.meal.mealId,
        );

        return wasAdded != isNowAdded;
      },
      listener: (context, state) {
        if (state is! ShoppingListMealIngredientLoaded) return;

        final portionCubit = context.read<PortionCubit>();
        final cubit = context.read<ShoppingListMealIngredientCubit>();
        if (!cubit.shouldShowNotification) return;

        final isNowAdded = state.items.any(
          (item) =>
              item['ingredientId'] == ingredient.ingredientId &&
              item['mealId'] == portionCubit.meal.mealId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowAdded
                  ? context.l10n
                      .addedIngredientToShoppingList(ingredient.ingredientName)
                  : context.l10n.removedIngredientFromShoppingList(
                      ingredient.ingredientName),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: BlocBuilder<ShoppingListMealIngredientCubit,
          ShoppingListMealIngredientState>(
        builder: (context, state) {
          final portionCubit = context.read<PortionCubit>();
          final currentAmount = baseAmount * portionCubit.state;

          bool isAdded = false;
          int? savedPortionCount;

          if (state is ShoppingListMealIngredientLoaded) {
            final items = state.items;

            isAdded = items.any(
              (item) =>
                  item['ingredientId'] == ingredient.ingredientId &&
                  item['mealId'] == portionCubit.meal.mealId,
            );

            if (isAdded) {
              final existingItem = items.firstWhere(
                (item) =>
                    item['ingredientId'] == ingredient.ingredientId &&
                    item['mealId'] == portionCubit.meal.mealId,
              );
              savedPortionCount = existingItem['portionCount'] as int?;
            }

            // ✅ Aktualizuj porcję, jeśli zmieniono
            if (isAdded &&
                savedPortionCount != null &&
                savedPortionCount != portionCubit.state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context
                    .read<ShoppingListMealIngredientCubit>()
                    .updateIngredientPortion(
                      ingredient,
                      portionCubit.meal,
                      newPortionCount: portionCubit.state,
                      suppressNotification: true,
                    );
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '• ${ingredient.ingredientName} ${currentAmount.toStringAsFixed(0)} ${ingredient.unit}',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final cubit =
                        context.read<ShoppingListMealIngredientCubit>();
                    if (isAdded) {
                      cubit.removeIngredient(ingredient, portionCubit.meal);
                    } else {
                      cubit.addIngredient(
                        ingredient,
                        portionCubit.meal,
                        portionCount: portionCubit.state,
                      );
                    }
                  },
                  icon: Icon(
                    isAdded ? Icons.check_circle : Icons.add_circle_outline,
                    color: isAdded ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
