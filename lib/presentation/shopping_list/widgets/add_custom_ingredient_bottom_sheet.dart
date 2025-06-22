import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';

class AddCustomIngredientBottomSheet extends StatefulWidget {
  const AddCustomIngredientBottomSheet({super.key});

  @override
  State<AddCustomIngredientBottomSheet> createState() =>
      _AddCustomIngredientBottomSheetState();
}

class _AddCustomIngredientBottomSheetState
    extends State<AddCustomIngredientBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ShoppingListCubit>().addCustomIngredient(text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 24, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.addToShoppingList,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: context.l10n.product,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
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
