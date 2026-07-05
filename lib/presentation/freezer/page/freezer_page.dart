import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/common/widgets/page_header/page_header.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        elevation: 0,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.background),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: PageHeader(
                      kicker: 'CO MASZ W ZAPASIE',
                      title: 'Zamrażarka',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.ac_unit, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<FreezerItemCubit, FreezerItemState>(
                  builder: (context, state) {
                    if (state is FreezerItemLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is FreezerItemError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      );
                    }
                    if (state is FreezerItemLoaded) {
                      final grouped = _groupByCategory(state.items);

                      if (state.items.isEmpty) {
                        return const Center(
                          child: Text(
                            'Brak pozycji w zamrażarce',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final category = grouped.keys.elementAt(index);
                          final items = grouped[category]!;

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
            ],
          ),
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
