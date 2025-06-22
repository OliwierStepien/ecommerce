import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class AddCustomIngredientBottomSheet extends StatefulWidget {
  final GetAllIngredientsUseCase getAllIngredientsUseCase;

  const AddCustomIngredientBottomSheet({
    super.key,
    required this.getAllIngredientsUseCase,
  });

  @override
  State<AddCustomIngredientBottomSheet> createState() =>
      _AddCustomIngredientBottomSheetState();
}

class _AddCustomIngredientBottomSheetState
    extends State<AddCustomIngredientBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<String?> _selectedCategory = ValueNotifier(null);

  void _submit(BuildContext context) {
    final name = _nameController.text.trim();
    final category = _selectedCategory.value ?? 'Inne';

    if (name.isEmpty) return;

    context
        .read<ShoppingListCubit>()
        .addCustomIngredient(name, category: category);
    Navigator.of(context).pop();

    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomIngredientCubit()..loadCategories(),
      child: Padding(
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.product,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            BlocBuilder<CustomIngredientCubit, CustomIngredientState>(
              builder: (context, state) {
                if (state is CustomIngredientLoading) {
                  return const CircularProgressIndicator();
                } else if (state is CustomIngredientLoaded) {
                  final categories = [...state.categories]..sort();

                  return ValueListenableBuilder<String?>(
                    valueListenable: _selectedCategory,
                    builder: (_, value, __) {
                      return DropdownButtonFormField<String>(
                        value: categories.contains(value) ? value : null,
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
                        onChanged: (val) => _selectedCategory.value = val,
                      );
                    },
                  );
                } else {
                  return const Text("Błąd podczas ładowania kategorii");
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty
                  ? null
                  : () => _submit(context),
              child: Text(context.l10n.add),
            ),
          ],
        ),
      ),
    );
  }
}
