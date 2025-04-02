import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class MealIngredient extends StatelessWidget {
  final MealEntity mealEntity;
  const MealIngredient({
    super.key,
    required this.mealEntity,
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
                const Text(
                  "Składniki:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "Dodaj do listy",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                      _buildIngredientItem(context, ingredient, mealEntity),
                      const Divider(height: 10, thickness: 0.5),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

Widget _buildIngredientItem(
    BuildContext context, String ingredient, MealEntity mealEntity) {
  return BlocListener<ShoppingListCubit, List<Map<String, dynamic>>>(
    listenWhen: (previous, current) {
      final wasAdded = previous.any((item) =>
          item['ingredient'] == ingredient && item['mealId'] == mealEntity.mealId);
      final isNowAdded = current.any((item) =>
          item['ingredient'] == ingredient && item['mealId'] == mealEntity.mealId);
      return wasAdded != isNowAdded;
    },
    listener: (context, state) {
      final cubit = context.read<ShoppingListCubit>();
      if (!cubit.shouldShowNotification) return;

      final isNowAdded = state.any((item) =>
          item['ingredient'] == ingredient && item['mealId'] == mealEntity.mealId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowAdded
                ? 'Dodano "$ingredient" do listy zakupów'
                : 'Usunięto "$ingredient" z listy zakupów',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    },
    child: BlocBuilder<ShoppingListCubit, List<Map<String, dynamic>>>(
      builder: (context, state) {
        final isAdded = state.any((item) =>
            item['ingredient'] == ingredient && item['mealId'] == mealEntity.mealId);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('• $ingredient'),
              ),
              IconButton(
                onPressed: () {
                  context.read<ShoppingListCubit>()
                    .addOrRemoveIngredient(ingredient, mealEntity);
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