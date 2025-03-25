import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class MealFirebaseService {
  Future<List<Map<String, dynamic>>> getMeals();
  Future<List<Map<String, dynamic>>> getMealsByCategoryId(String categoryId);
  Future<List<Map<String, dynamic>>> getMealsByTitle(String title);
  Future<bool> addOrRemoveFavoriteMeal(MealEntity meal);
  Future<bool> isFavorite(String mealId);
  Future<List<Map<String, dynamic>>> getFavoritesMeals();
  Future<bool> addOrRemoveShoppingListIngredient(MealEntity meal);
  Future<bool> isIngredientInShoppingList(MealEntity meal);
  Future<List<Map<String, dynamic>>> getShoppingList();
}

class MealFirebaseServiceImpl extends MealFirebaseService {
  @override
  Future<List<Map<String, dynamic>>> getMeals() async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .where('categoriesId', arrayContains: categoryId)
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getMealsByTitle(String title) async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .get()
          .timeout(const Duration(seconds: 15));
      final filteredMeals = returnedData.docs
          .map((e) => e.data())
          .where((meal) =>
              meal['title'].toLowerCase().contains(title.toLowerCase()))
          .toList();
      return filteredMeals;
    });
  }

  @override
  Future<bool> addOrRemoveFavoriteMeal(MealEntity meal) async {
    return handleFirestoreException(() async {
      final user = FirebaseAuth.instance.currentUser;
      final meals = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('Favorites')
          .where('mealId', isEqualTo: meal.mealId)
          .get()
          .timeout(const Duration(seconds: 15));

      if (meals.docs.isNotEmpty) {
        await meals.docs.first.reference.delete();
        return false;
      } else {
        final mealModel = MealMapper.toModel(meal);
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .collection('Favorites')
            .add(mealModel.toMap());
        return true;
      }
    });
  }

  @override
  Future<bool> isFavorite(String mealId) async {
    return handleFirestoreException(() async {
      final user = FirebaseAuth.instance.currentUser;
      final meals = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('Favorites')
          .where('mealId', isEqualTo: mealId)
          .get()
          .timeout(const Duration(seconds: 15));
      return meals.docs.isNotEmpty;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getFavoritesMeals() async {
    return handleFirestoreException(() async {
      final user = FirebaseAuth.instance.currentUser;
      final returnedData = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('Favorites')
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Future<bool> addOrRemoveShoppingListIngredient(MealEntity meal) async {
    return handleFirestoreException(() async {
      final user = FirebaseAuth.instance.currentUser;
      final returnedData = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('ShoppingList')
          .where('mealId', isEqualTo: meal.mealId)
          .get()
          .timeout(const Duration(seconds: 15));

      if (returnedData.docs.isNotEmpty) {
        await returnedData.docs.first.reference.delete();
        return false;
      } else {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .collection('ShoppingList')
            .add({
          'mealId': meal.mealId,
          'title': meal.title,
          'ingredients': meal.ingredients,
        });
        return true;
      }
    });
  }

  @override
  Future<bool> isIngredientInShoppingList(MealEntity meal) async {
    return handleFirestoreException(() async {
      final user = FirebaseAuth.instance.currentUser;
      final ingredients = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('ShoppingList')
          .where('ingredient', isEqualTo: meal.ingredients)
          .where('mealId', isEqualTo: meal.mealId)
          .get()
          .timeout(const Duration(seconds: 15));
      return ingredients.docs.isNotEmpty;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getShoppingList() async {
    return handleFirestoreException(() async {
      final user = FirebaseAuth.instance.currentUser;
      final returnedData = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('ShoppingList')
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((doc) => doc.data()).toList();
    });
  }
}
