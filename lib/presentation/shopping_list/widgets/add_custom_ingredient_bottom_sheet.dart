import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/error_message/error_message.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_state.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class AddCustomIngredientBottomSheet extends StatelessWidget {
  final GetAllIngredientsUseCase getAllIngredientsUseCase;

  const AddCustomIngredientBottomSheet({
    super.key,
    required this.getAllIngredientsUseCase,
  });

void _submit(BuildContext context) {
  final cubit = context.read<CustomIngredientCubit>();
  final ingredient = cubit.getCustomIngredient();

  if (ingredient == null) return;

  context.read<ShoppingListCubit>().addCustomIngredient(ingredient);
  Navigator.of(context).pop();
  cubit.clearForm();
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomIngredientCubit(getAllIngredientsUseCase),
      child: Builder(
        builder: (context) {
          final cubit = context.read<CustomIngredientCubit>();

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
                BlocBuilder<CustomIngredientCubit, CustomIngredientState>(
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
                BlocBuilder<CustomIngredientCubit, CustomIngredientState>(
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
                        onRetry: () =>
                            context.read<CustomIngredientCubit>().loadCategories(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<CustomIngredientCubit, CustomIngredientState>(
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