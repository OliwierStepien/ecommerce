import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/presentation/freezer/bloc/freezer_item_cubit.dart';

class FreezerItemTile extends StatelessWidget {
  final FreezerItemEntity item;

  const FreezerItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => _edit(context),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: () => _remove(context),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }

  void _remove(BuildContext context) {
    final cubit = context.read<FreezerItemCubit>();
    cubit.removeItem(item.itemId);

    if (!cubit.shouldShowNotification) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usunięto: ${item.name}'),
        action: SnackBarAction(
          label: 'Cofnij',
          textColor: Colors.white,
          onPressed: () => cubit.restoreLastRemoved(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: item.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edytuj'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nowa nazwa'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zamknij'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );

    final trimmed = (newName ?? '').trim();
    if (trimmed.isEmpty) return;
    if (!context.mounted) return;

    final cubit = context.read<FreezerItemCubit>();
    await cubit.updateItem(
      item.copyWith(name: trimmed),
      suppressNotification: true,
    );
  }
}