import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:flutter/material.dart';

class ShoppingListPage extends StatelessWidget {
  final List<MealEntity> meals;

  const ShoppingListPage({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        title: Text('Lista zakupów'),
      ),
      body: _ingredients(meals),
    );
  }

  Widget _ingredients(List<MealEntity> meals) {
    // Pobieramy unikalne składniki ze wszystkich posiłków
    final uniqueIngredients = meals
        .expand((meal) => meal.ingredients)
        .toSet() // Usuwamy duplikaty
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: uniqueIngredients.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                uniqueIngredients[index], // Wyświetlamy nazwę składnika
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.shopping_cart, color: Colors.green), // Ikona zakupów
            ),
          );
        },
      ),
    );
  }
}