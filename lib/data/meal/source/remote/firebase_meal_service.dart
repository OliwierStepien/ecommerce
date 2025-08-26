
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseMealService {
  Future<List<IngredientModel>> getIngredientsForMeals(List<String> mealIds);
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
  static const int _maxWhereInLimit = 10;

  FirebaseMealServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<IngredientModel>> getIngredientsForMeals(List<String> mealIds) {
    return handleFirestoreException(() async {
      
      // Dzielimy listę na partie (Firestore limit to 10 dla whereIn)
      final List<List<String>> chunks = [];
      for (var i = 0; i < mealIds.length; i += _maxWhereInLimit) {
        chunks.add(mealIds.sublist(i, 
            i + _maxWhereInLimit > mealIds.length ? mealIds.length : i + _maxWhereInLimit));
      }

      final List<IngredientModel> allIngredients = [];
      
      for (final chunk in chunks) {
        final returnedData = await _firestore
            .collection("Ingredients")
            .where('mealId', whereIn: chunk)
            .get()
            .timeout(const Duration(seconds: 15));

        allIngredients.addAll(
          returnedData.docs.map((e) => IngredientModel.fromMap(e.data())).toList()
        );
      }

      return allIngredients;
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

  Future<List<MealModel>> _getMealsWithIngredients(
      Iterable<QueryDocumentSnapshot> docs) async {
    
    final mealIds = docs.map((doc) => doc['mealId'] as String).toList();
    final allIngredients = await getIngredientsForMeals(mealIds);
    
    // Grupujemy składniki według mealId
    final ingredientsByMealId = <String, List<IngredientModel>>{};
    for (final ingredient in allIngredients) {
      ingredientsByMealId.putIfAbsent(ingredient.mealId, () => []).add(ingredient);
    }

    return docs.map((doc) {
      final mealId = doc['mealId'] as String;
      final ingredients = ingredientsByMealId[mealId] ?? [];
      
      return MealModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
      });
    }).toList();
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