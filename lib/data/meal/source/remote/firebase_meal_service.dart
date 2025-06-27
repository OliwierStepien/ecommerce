import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseMealService {
  Future<List<Map<String, dynamic>>> getIngredientsForMeal(String mealId);
  Future<List<Map<String, dynamic>>> getAllIngredients();
  Future<List<Map<String, dynamic>>> getMeals();
  Future<List<Map<String, dynamic>>> getMealsByCategoryId(String categoryId);
  Future<List<Map<String, dynamic>>> getMealsByTitle(String title);
  Future<bool> addOrRemoveFavoriteMeal(MealEntity meal);
  Future<List<Map<String, dynamic>>> getFavoritesMeals();
  Future<bool> addOrRemoveShoppingListIngredient(MealEntity meal);
  Future<bool> isIngredientInShoppingList(MealEntity meal);
  Future<List<Map<String, dynamic>>> getShoppingList();
  Future<List<Map<String, dynamic>>> getMealsByIsVegetarian(bool isVegetarian);
  Future<List<Map<String, dynamic>>> getVegetarianMealsByCategoryId(
      String categoryId);
  Future<List<Map<String, dynamic>>> getVegetarianMealsByTitle(String title);
}

class FirebaseMealServiceImpl extends FirebaseMealService {
  @override
  Future<List<Map<String, dynamic>>> getIngredientsForMeal(String mealId) {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Ingredients")
          .where('mealId', isEqualTo: mealId)
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAllIngredients() {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Ingredients")
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getMeals() async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .get()
          .timeout(const Duration(seconds: 15));

      final meals = returnedData.docs.map((e) => e.data()).toList();

      final mealsWithIngredients = await Future.wait(meals.map((meal) async {
        final ingredients =
            await getIngredientsForMeal(meal['mealId'] as String);
        return {
          ...meal,
          'ingredients': ingredients,
        };
      }));

      return mealsWithIngredients;
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
      final meals = returnedData.docs.map((e) => e.data()).toList();

      final mealsWithIngredients = await Future.wait(meals.map((meal) async {
        final ingredients =
            await getIngredientsForMeal(meal['mealId'] as String);
        return {
          ...meal,
          'ingredients': ingredients,
        };
      }));

      return mealsWithIngredients;
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

      final mealsWithIngredients =
          await Future.wait(filteredMeals.map((meal) async {
        final ingredients =
            await getIngredientsForMeal(meal['mealId'] as String);
        return {
          ...meal,
          'ingredients': ingredients,
        };
      }));

      return mealsWithIngredients;
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

  @override
  Future<List<Map<String, dynamic>>> getMealsByIsVegetarian(
      bool isVegetarian) async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .where('isVegetarian', isEqualTo: isVegetarian)
          .get()
          .timeout(const Duration(seconds: 15));
      final meals = returnedData.docs.map((e) => e.data()).toList();

      final mealsWithIngredients = await Future.wait(meals.map((meal) async {
        final ingredients =
            await getIngredientsForMeal(meal['mealId'] as String);
        return {
          ...meal,
          'ingredients': ingredients,
        };
      }));

      return mealsWithIngredients;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .where('categoriesId', arrayContains: categoryId)
          .where('isVegetarian', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 15));
      final meals = returnedData.docs.map((e) => e.data()).toList();

      final mealsWithIngredients = await Future.wait(meals.map((meal) async {
        final ingredients =
            await getIngredientsForMeal(meal['mealId'] as String);
        return {
          ...meal,
          'ingredients': ingredients,
        };
      }));

      return mealsWithIngredients;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVegetarianMealsByTitle(
      String title) async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .where('isVegetarian', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 15));

      final filteredMeals = returnedData.docs
          .map((e) => e.data())
          .where((meal) =>
              meal['title'].toLowerCase().contains(title.toLowerCase()))
          .toList();

      final mealsWithIngredients =
          await Future.wait(filteredMeals.map((meal) async {
        final ingredients =
            await getIngredientsForMeal(meal['mealId'] as String);
        return {
          ...meal,
          'ingredients': ingredients,
        };
      }));

      return mealsWithIngredients;
    });
  }
}
