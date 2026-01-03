import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/presentation/freezer/bloc/freezer_item_cubit.dart';

class AddFreezerItemBottomSheet extends StatefulWidget {
  const AddFreezerItemBottomSheet({super.key});

  @override
  State<AddFreezerItemBottomSheet> createState() =>
      _AddFreezerItemBottomSheetState();
}

class _AddFreezerItemBottomSheetState extends State<AddFreezerItemBottomSheet> {
  final _controller = TextEditingController();
  String _category = 'Produkty';

  static const _categories = ['Posiłki', 'Produkty'];

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final item = FreezerItemEntity(
      itemId: 'freezer_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _category,
    );

    context.read<FreezerItemCubit>().addItem(item);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _controller.text.trim().isEmpty;

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
          Text('Dodaj do zamrażarki', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nazwa',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Kategoria',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Produkty'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isDisabled ? null : _submit,
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}