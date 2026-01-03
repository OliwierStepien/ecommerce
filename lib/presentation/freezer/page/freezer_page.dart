import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/presentation/freezer/bloc/freezer_item_cubit.dart';
import 'package:mealapp/presentation/freezer/bloc/freezer_item_state.dart';
import 'package:mealapp/presentation/freezer/widget/add_freezer_item_bottom_sheet.dart';
import 'package:mealapp/presentation/freezer/widget/freezer_item_tile.dart';

class FreezerPage extends StatelessWidget {
  const FreezerPage({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddFreezerItemBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        title: Text('Zamrażarka'),
        hideBack: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<FreezerItemCubit, FreezerItemState>(
          builder: (context, state) {
            if (state is FreezerItemLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FreezerItemError) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            }
            if (state is FreezerItemLoaded) {
              final grouped = _groupByCategory(state.items);

              if (state.items.isEmpty) {
                return const Center(child: Text('Brak pozycji w zamrażarce'));
              }

              return ListView.builder(
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final category = grouped.keys.elementAt(index);
                  final items = grouped[category]!;

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
                      ...items.map((e) => FreezerItemTile(item: e)),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _groupByCategory(List items) {
    final map = <String, List<dynamic>>{
      'Posiłki': [],
      'Produkty': [],
    };

    for (final i in items) {
      final c = (i.category == 'Posiłki') ? 'Posiłki' : 'Produkty';
      map[c]!.add(i);
    }

    // usuń puste sekcje z listy
    map.removeWhere((k, v) => v.isEmpty);
    return map;
  }
}