import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';
import 'package:mealapp/presentation/shopping_list/widgets/shopping_list_item.dart';
import 'package:mealapp/presentation/shopping_list/widgets/add_custom_ingredient_bottom_sheet.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';
import 'package:mealapp/service_locator.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  void _showAddIngredientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddCustomIngredientBottomSheet(
        getAllIngredientsUseCase: sl<GetAllIngredientsUseCase>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Text(context.l10n.shoppingList),
        hideBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ShoppingListCubit, List<Map<String, dynamic>>>(
                builder: (context, state) {
                  final Map<String, List<Map<String, dynamic>>> groupedItems =
                      {};

                  for (var item in state) {
                    final category = item['ingredientCategory'] ?? 'Inne';
                    groupedItems.putIfAbsent(category, () => []).add(item);
                  }

                  return ListView.builder(
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final category = groupedItems.keys.elementAt(index);
                      final items = groupedItems[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          ...items.map((item) {
                            final mealEntity =
                                item['mealEntity'] as MealEntity?;
                            final scaledAmount = item['scaledAmount'] as num?;

                            final ingredient = IngredientEntity(
                              ingredientId: item['ingredientId'] ?? '',
                              ingredientName: item['ingredientName'] ?? '',
                              amountPerPortion:
                                  item['amountPerPortion'] as num?,
                              unit: item['unit'] ?? '',
                              ingredientCategory:
                                  item['ingredientCategory'] ?? 'Inne',
                              mealId: mealEntity?.mealId ??
                                  '', // custom ingredient has no mealId
                            );

                            return ShoppingListItem(
                              ingredient: ingredient,
                              meal: mealEntity,
                              scaledAmount: scaledAmount,
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                mini: true,
                onPressed: () => _showAddIngredientSheet(context),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
