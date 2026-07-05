import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
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

// ✅ NOWE: UseCase do czyszczenia listy zakupów (bulk delete online + fallback offline)
import 'package:mealapp/domain/shopping_list_clear/usecase/clear_shopping_list_usecase.dart';

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

  Future<void> _confirmClearAll(BuildContext context) async {
    // ✅ pobierz cubity na początku (zanim pojawią się async gaps)
    final mealCubit = context.read<ShoppingListMealIngredientCubit>();
    final customCubit = context.read<ShoppingListCustomItemCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Wyczyścić listę zakupów?'),
        content: const Text('Czy na pewno chcesz usunąć wszystkie pozycje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Usuń wszystko',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // ✅ natychmiast czyść UI (bez czekania)
    mealCubit.clearView();
    customCubit.clearView();

    final res = await sl<ClearShoppingListUseCase>().call();
    if (!context.mounted) return;

    await res.fold(
      (f) async {
        messenger.showSnackBar(
          SnackBar(content: Text('Błąd: $f')),
        );

        // opcjonalnie: przywróć stan przez reload, żeby UI nie zostało puste po błędzie
        await mealCubit.reload();
        await customCubit.reload();
      },
      (_) async {
        // ✅ po sukcesie dociągnij z Hive dla spójności
        await mealCubit.reload();
        await customCubit.reload();

        if (!context.mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Lista zakupów została wyczyszczona.'),
          duration: Duration(seconds: 2),),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              PageHeader(
                kicker: 'SPIŻARNIA',
                title: context.l10n.shoppingList,
              ),
              const SizedBox(height: 16),
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
                              style: const TextStyle(color: AppColors.danger),
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
                                      'isChecked': item.isChecked,
                                      // opcjonalnie: porządek w mapie (nie używasz teraz)
                                      'portionCount': null,
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
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.only(bottom: 6),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom:
                                          BorderSide(color: AppColors.hairline),
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
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
                                    isChecked:
                                        item['isChecked'] as bool? ?? false,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: 'openGroceriesBtn',
                    mini: true,
                    elevation: 0,
                    backgroundColor: AppColors.background,
                    shape: const CircleBorder(
                      side: BorderSide(color: AppColors.hairline),
                    ),
                    onPressed: () => _showGroceriesSheet(context),
                    child: const Icon(Icons.menu, color: Color(0xFF7A6D5B)),
                  ),

                  // 🗑️ CLEAR ALL – bez tekstu
                  FloatingActionButton(
                    heroTag: 'clearAllBtn',
                    mini: true,
                    elevation: 0,
                    backgroundColor: AppColors.background,
                    shape: const CircleBorder(
                      side: BorderSide(color: AppColors.hairline),
                    ),
                    onPressed: () => _confirmClearAll(context),
                    child:
                        const Icon(Icons.delete_forever, color: AppColors.danger),
                  ),

                  FloatingActionButton(
                    heroTag: 'addBtn',
                    mini: true,
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    onPressed: () => _showAddIngredientSheet(context),
                    child: const Icon(Icons.add, color: AppColors.background),
                  ),
                ],
              ),
            ],
          ),
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
    return {
      for (final key in sortedKeys)
        // odhaczone pozycje opadają na dół swojej kategorii
        // (partycjonowanie zamiast sort — List.sort nie jest stabilny)
        key: [
          ...groupedItems[key]!.where((i) => i['isChecked'] != true),
          ...groupedItems[key]!.where((i) => i['isChecked'] == true),
        ]
    };
  }
}
