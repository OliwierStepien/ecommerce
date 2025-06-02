import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_cubit.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/shopping_list/widgets/shopping_list_item.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        hideBack: true,
        title: Text(context.l10n.shoppingList),
      ),
      body: BlocBuilder<ShoppingListCubit, List<Map<String, dynamic>>>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: state.length,
              itemBuilder: (BuildContext context, int index) {
                final item = state[index];
                final ingredient = item['ingredient']!;
                final title = item['title']!;
                final mealEntity = item['mealEntity'] as MealEntity;

                return ShoppingListItem(
                  ingredient: ingredient,
                  title: title,
                  mealEntity: mealEntity,
                );
              },
            ),
          );
        },
      ),
    );
  }
}