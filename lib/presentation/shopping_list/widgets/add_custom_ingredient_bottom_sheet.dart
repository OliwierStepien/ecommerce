import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/domain/ingredient/usecase/get_all_ingredients.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_category_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_category_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';

class AddCustomIngredientBottomSheet extends StatelessWidget {
  final GetAllIngredientsUseCase getAllIngredientsUseCase;

  const AddCustomIngredientBottomSheet({
    super.key,
    required this.getAllIngredientsUseCase,
  });

void _submit(BuildContext context) {
  final categoryCubit = context.read<CustomCategoryCubit>();
  final customCubit = context.read<ShoppingListCustomItemCubit>();
  final ingredient = categoryCubit.getCustomIngredient();

  if (ingredient == null) return;

  customCubit.addCustomIngredient(ingredient);
  Navigator.of(context).pop();
  categoryCubit.clearForm();

  // ✅ POKAŻ SNACKBAR po dodaniu składnika
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        context.l10n.addedIngredientToShoppingList(ingredient.customItemName),
      ),
      duration: const Duration(seconds: 1),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CustomCategoryCubit(getAllIngredientsUseCase),
        ),
      ],
      child: Builder(
        builder: (context) {
          final cubit = context.read<CustomCategoryCubit>();

          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.addToShoppingList,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                BlocBuilder<CustomCategoryCubit, CustomCategoryState>(
                  builder: (context, state) {
                    return TextField(
                      controller: cubit.nameController,
                      decoration: InputDecoration(
                        labelText: context.l10n.product,
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<CustomCategoryCubit, CustomCategoryState>(
                  builder: (context, state) {
                    if (state is CustomIngredientLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is CustomIngredientLoaded) {
                      final categories = [...state.categories]..sort();

                      return DropdownButtonFormField<String>(
                        value: cubit.selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Kategoria",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (val) => cubit.updateCategory(val),
                      );
                    } else if (state is CustomIngredientError) {
                      return ErrorMessage(
                        message: state.message,
                        onRetry: () => cubit.loadCategories(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<CustomCategoryCubit, CustomCategoryState>(
                  builder: (context, state) {
                    final isDisabled = state is! CustomIngredientLoaded ||
                        state.inputText.trim().isEmpty;

                    return ElevatedButton(
                      onPressed: isDisabled ? null : () => _submit(context),
                      child: Text(context.l10n.add),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}