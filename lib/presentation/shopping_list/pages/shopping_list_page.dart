import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/grocery/usecase/get_groceries.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/grocery/bloc/groceries_display_cubit.dart';
import 'package:mealapp/presentation/grocery/widget/groceries_bottom_sheet.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_state.dart';
import 'package:mealapp/presentation/shopping_list/widgets/shopping_list_item.dart';
import 'package:mealapp/presentation/shopping_list/widgets/add_custom_ingredient_bottom_sheet.dart';
import 'package:mealapp/domain/ingredient/usecase/get_all_ingredients.dart';
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

  void _showGroceriesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return BlocProvider(
          create: (_) => GroceriesDisplayCubit(
            useCase: sl<GetGroceriesUseCase>(),
          )..loadGroceries(),
          child: const GroceriesBottomSheet(),
        );
      },
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
              child: BlocBuilder<ShoppingListMealIngredientCubit,
                  ShoppingListMealIngredientState>(
                builder: (context, mealState) {
                  if (mealState is ShoppingListMealIngredientLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (mealState is ShoppingListMealIngredientError) {
                    return Center(child: Text(mealState.message));
                  }

                  if (mealState is ShoppingListMealIngredientLoaded) {
                    final mealItems = mealState.items;

                    return BlocBuilder<ShoppingListCustomItemCubit,
                        ShoppingListCustomItemState>(
                      builder: (context, customState) {
                        if (customState is ShoppingListCustomItemLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (customState is ShoppingListCustomItemError) {
                          return Center(
                            child: Text(
                              customState.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final customItems =
                            customState is ShoppingListCustomItemLoaded
                                ? customState.items.map((item) {
                                    return {
                                      'ingredientId': item.customItemId,
                                      'ingredientName': item.customItemName,
                                      'ingredientCategory':
                                          item.customItemCategory,
                                      'mealId': null,
                                      'title': '',
                                      'mealEntity': null,
                                      'amountPerPortion': null,
                                      'unit': '',
                                      'scaledAmount': null,
                                      'isCustom': true,
                                    };
                                  }).toList()
                                : <Map<String, dynamic>>[];

                        final combinedItems = [...mealItems, ...customItems];
                        final groupedItems =
                            _groupItemsByCategory(combinedItems);

                        return ListView.builder(
                          itemCount: groupedItems.length,
                          itemBuilder: (context, index) {
                            final category = groupedItems.keys.elementAt(index);
                            final items = groupedItems[category]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                                  final scaledAmount =
                                      item['scaledAmount'] as num?;

                                  final ingredient = IngredientEntity(
                                    ingredientId: item['ingredientId'] ?? '',
                                    ingredientName:
                                        item['ingredientName'] ?? '',
                                    amountPerPortion:
                                        item['amountPerPortion'] as num?,
                                    unit: item['unit'] ?? '',
                                    ingredientCategory:
                                        item['ingredientCategory'] ?? 'Inne',
                                    mealId: mealEntity?.mealId ?? '',
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
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 16),

            // ✅ DWA PRZYCISKI NA DOLE: LEWY (bottom sheet) + PRAWY (add)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: 'openGroceriesBtn',
                  mini: true,
                  onPressed: () => _showGroceriesSheet(context),
                  child: const Icon(Icons.menu),
                ),
                FloatingActionButton(
                  heroTag: 'addBtn',
                  mini: true,
                  onPressed: () => _showAddIngredientSheet(context),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByCategory(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (final item in items) {
      final category = item['ingredientCategory'] ?? 'Inne';
      groupedItems.putIfAbsent(category, () => []).add(item);
    }

    final sortedKeys = groupedItems.keys.toList()..sort();
    return {for (final key in sortedKeys) key: groupedItems[key]!};
  }
}
