import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/presentation/meal_details/bloc/shopping_list_cubit.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        title: Text('Lista zakupów'),
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

                return Card(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Z posiłku: $title',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final shoppingListCubit =
                                context.read<ShoppingListCubit>();
                            shoppingListCubit.addOrRemoveIngredient(
                              ingredient,
                              mealEntity,
                              suppressNotification: true,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Usunięto "$ingredient" z listy zakupów'),
                                action: SnackBarAction(
                                  label: 'Cofnij',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    shoppingListCubit
                                        .restoreLastRemovedIngredient();
                                  },
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
