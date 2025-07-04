import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseMealService {
  Future<List<IngredientModel>> getIngredientsForMeal(String mealId);
  Future<List<IngredientModel>> getAllIngredients();
  Future<List<MealModel>> getMeals();
  Future<List<MealModel>> getMealsByCategoryId(String categoryId);
  Future<List<MealModel>> getMealsByTitle(String title);
  Future<bool> addOrRemoveShoppingListIngredient(
      MealModel meal, IngredientModel ingredient, int portionCount);
  Future<bool> isIngredientInShoppingList(MealModel meal);
  Future<List<MealModel>> getShoppingList();
  Future<List<MealModel>> getMealsByIsVegetarian(bool isVegetarian);
  Future<List<MealModel>> getVegetarianMealsByCategoryId(String categoryId);
  Future<List<MealModel>> getVegetarianMealsByTitle(String title);
}

class FirebaseMealServiceImpl implements FirebaseMealService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseMealServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<IngredientModel>> getIngredientsForMeal(String mealId) {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Ingredients")
          .where('mealId', isEqualTo: mealId)
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs
          .map((e) => IngredientModel.fromMap(e.data()))
          .toList();
    });
  }

  @override
  Future<List<IngredientModel>> getAllIngredients() {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Ingredients")
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs
          .map((e) => IngredientModel.fromMap(e.data()))
          .toList();
    });
  }

  @override
  Future<List<MealModel>> getMeals() async {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Meals")
          .get()
          .timeout(const Duration(seconds: 15));

      return await _getMealsWithIngredients(returnedData.docs);
    });
  }

  @override
  Future<List<MealModel>> getMealsByCategoryId(String categoryId) async {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Meals")
          .where('categoriesId', arrayContains: categoryId)
          .get()
          .timeout(const Duration(seconds: 15));

      return await _getMealsWithIngredients(returnedData.docs);
    });
  }

  @override
  Future<List<MealModel>> getMealsByTitle(String title) async {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Meals")
          .get()
          .timeout(const Duration(seconds: 15));

      final filteredDocs = returnedData.docs.where((doc) =>
          doc['title'].toString().toLowerCase().contains(title.toLowerCase()));

      return await _getMealsWithIngredients(filteredDocs);
    });
  }

  Future<List<MealModel>> _getMealsWithIngredients(
      Iterable<QueryDocumentSnapshot> docs) async {
    return await Future.wait(docs.map((doc) async {
      final ingredients = await getIngredientsForMeal(doc['mealId'] as String);
      return MealModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
      });
    }));
  }

  @override
  Future<bool> addOrRemoveShoppingListIngredient(
      MealModel meal, IngredientModel ingredient, int portionCount) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      final returnedData = await _firestore
          .collection("Users")
          .doc(user?.uid)
          .collection('ShoppingList')
          .where('ingredientId', isEqualTo: ingredient.ingredientId)
          .where('mealId', isEqualTo: meal.mealId)
          .get()
          .timeout(const Duration(seconds: 15));

      if (returnedData.docs.isNotEmpty) {
        await returnedData.docs.first.reference.delete();
        return false;
      } else {
        // Oblicz ilość składnika uwzględniając liczbę porcji
        final scaledAmount = ingredient.amountPerPortion != null
            ? ingredient.amountPerPortion! * portionCount
            : null;

        await _firestore
            .collection("Users")
            .doc(user?.uid)
            .collection('ShoppingList')
            .add({
          'mealId': meal.mealId,
          'title': meal.title,
          'ingredientId': ingredient.ingredientId,
          'ingredientName': ingredient.ingredientName,
          'amountPerPortion': ingredient.amountPerPortion,
          'scaledAmount': scaledAmount,
          'unit': ingredient.unit,
          'ingredientCategory': ingredient.ingredientCategory,
          'portionCount': portionCount,
        });
        return true;
      }
    });
  }

  @override
  Future<bool> isIngredientInShoppingList(MealModel meal) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      final ingredients = await _firestore
          .collection("Users")
          .doc(user?.uid)
          .collection('ShoppingList')
          .where('mealId', isEqualTo: meal.mealId)
          .get()
          .timeout(const Duration(seconds: 15));
      return ingredients.docs.isNotEmpty;
    });
  }

  @override
  @override
  Future<List<MealModel>> getShoppingList() async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      final returnedData = await _firestore
          .collection("Users")
          .doc(user?.uid)
          .collection('ShoppingList')
          .get()
          .timeout(const Duration(seconds: 15));

      return returnedData.docs.map((doc) {
        final data = doc.data();
        return MealModel(
          title: data['title'] as String,
          mealId: data['mealId'] as String,
          categoryId: [],
          image: '',
          ingredients: [
            IngredientModel(
              ingredientId: data['ingredientId'] as String,
              ingredientName: data['ingredientName'] as String,
              amountPerPortion: data['amountPerPortion'] as num?,
              unit: data['unit'] as String,
              ingredientCategory: data['ingredientCategory'] as String,
              mealId: data['mealId'] as String,
            )
          ],
          steps: [],
          isVegetarian: false,
        );
      }).toList();
    });
  }

  @override
  Future<List<MealModel>> getMealsByIsVegetarian(bool isVegetarian) async {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Meals")
          .where('isVegetarian', isEqualTo: isVegetarian)
          .get()
          .timeout(const Duration(seconds: 15));

      return await _getMealsWithIngredients(returnedData.docs);
    });
  }

  @override
  Future<List<MealModel>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Meals")
          .where('categoriesId', arrayContains: categoryId)
          .where('isVegetarian', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 15));

      return await _getMealsWithIngredients(returnedData.docs);
    });
  }

  @override
  Future<List<MealModel>> getVegetarianMealsByTitle(String title) async {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Meals")
          .where('isVegetarian', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 15));

      final filteredDocs = returnedData.docs.where((doc) =>
          doc['title'].toString().toLowerCase().contains(title.toLowerCase()));

      return await _getMealsWithIngredients(filteredDocs);
    });
  }
}
