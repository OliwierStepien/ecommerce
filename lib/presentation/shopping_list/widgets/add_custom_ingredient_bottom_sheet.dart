import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class AddCustomIngredientBottomSheet extends StatefulWidget {
  const AddCustomIngredientBottomSheet({super.key});

  @override
  State<AddCustomIngredientBottomSheet> createState() =>
      _AddCustomIngredientBottomSheetState();
}

class _AddCustomIngredientBottomSheetState
    extends State<AddCustomIngredientBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final ingredientsResult = await sl<MealRepository>().getAllIngredients();

      ingredientsResult.fold(
        (failure) {
          setState(() {
            _categories = ['Inne'];
            _selectedCategory = 'Inne';
            _isLoading = false;
          });
        },
        (ingredients) {
          final uniqueCategories = ingredients
              .map((i) => i.ingredientCategory)
              .where((category) => category.trim().isNotEmpty)
              .toSet()
              .toList();

          if (!uniqueCategories.contains('Inne')) {
            uniqueCategories.insert(0, 'Inne');
          }

          setState(() {
            _categories = uniqueCategories;
            _selectedCategory = 'Inne';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _categories = ['Inne'];
        _selectedCategory = 'Inne';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<ShoppingListCubit>().addCustomIngredient(
          name,
          category: _selectedCategory ?? 'Inne',
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l10n.product,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    // labelText: context.l10n.category,
                    labelText: "kategoria",

                    border: const OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: Text(context.l10n.add),
          ),
        ],
      ),
    );
  }
}
