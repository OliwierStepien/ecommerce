import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/portion_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class MealIngredient extends StatelessWidget {
  final MealEntity mealEntity;
  const MealIngredient({
    super.key,
    required this.mealEntity,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortionCubit, int>(
      builder: (context, portionCount) {
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
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.shopping_cart, color: Colors.green.shade700),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: mealEntity.ingredients
                    .map(
                      (ingredient) => Column(
                        children: [
                          _buildIngredientItem(
                            context,
                            ingredient,
                            mealEntity,
                            portionCount,
                          ),
                          const Divider(height: 10, thickness: 0.5),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIngredientItem(
    BuildContext context,
    IngredientEntity ingredient,
    MealEntity mealEntity,
    int portionCount,
  ) {
    final scaledAmount = ingredient.amountPerPortion! * portionCount;

    return BlocListener<ShoppingListCubit, List<Map<String, dynamic>>>(
      listenWhen: (previous, current) {
        final wasAdded = previous.any((item) =>
            item['ingredientId'] == ingredient.ingredientId &&
            item['mealId'] == mealEntity.mealId);
        final isNowAdded = current.any((item) =>
            item['ingredientId'] == ingredient.ingredientId &&
            item['mealId'] == mealEntity.mealId);
        return wasAdded != isNowAdded;
      },
      listener: (context, state) {
        final cubit = context.read<ShoppingListCubit>();
        if (!cubit.shouldShowNotification) return;

        final isNowAdded = state.any((item) =>
            item['ingredientId'] == ingredient.ingredientId &&
            item['mealId'] == mealEntity.mealId);

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
      child: BlocBuilder<ShoppingListCubit, List<Map<String, dynamic>>>(
        builder: (context, state) {
          final isAdded = state.any((item) =>
              item['ingredientId'] == ingredient.ingredientId &&
              item['mealId'] == mealEntity.mealId);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '• ${ingredient.ingredientName} ${scaledAmount.toStringAsFixed(0)} ${ingredient.unit}',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (isAdded) {
                      context.read<ShoppingListCubit>().removeIngredient(
                            ingredient,
                            mealEntity,
                          );
                    } else {
                      context.read<ShoppingListCubit>().addIngredient(
                            ingredient,
                            mealEntity,
                            portionCount: portionCount,
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
