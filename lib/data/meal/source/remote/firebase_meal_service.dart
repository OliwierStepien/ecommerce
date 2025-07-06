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
  Future<List<MealModel>> getMealsByIsVegetarian(bool isVegetarian);
  Future<List<MealModel>> getVegetarianMealsByCategoryId(String categoryId);
  Future<List<MealModel>> getVegetarianMealsByTitle(String title);
}

class FirebaseMealServiceImpl implements FirebaseMealService {
  final FirebaseFirestore _firestore;

  FirebaseMealServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

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
