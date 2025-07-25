import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/meal/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

abstract class FirebaseShoppingListMealIngredientService {
  Future<void> addMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount);
  Future<void> removeMealIngredientFromShoppingList(
      MealModel meal, IngredientModel ingredient);
  Future<List<MealModel>> getMealIngredientFromShoppingList();
  Future<void> restoreMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount);
}

class FirebaseShoppingListMealIngredientServiceImpl
    implements FirebaseShoppingListMealIngredientService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseShoppingListMealIngredientServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userShoppingMealItemsCollection() {
    final user = _auth.currentUser;

    if (user == null) throw UnauthorizedException();
    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('ShoppingList');
  }

  @override
  Future<void> addMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount) async {
    return handleFirestoreException(() async {
      final docId = '${meal.mealId}_${ingredient.ingredientId}';
      final scaledAmount = ingredient.amountPerPortion != null
          ? ingredient.amountPerPortion! * portionCount
          : null;

      await _userShoppingMealItemsCollection()
          .doc(docId) // <-- Klucz dokumentu, zapobiega duplikatom
          .set({
        'mealId': meal.mealId,
        'title': meal.title,
        'ingredientId': ingredient.ingredientId,
        'ingredientName': ingredient.ingredientName,
        'amountPerPortion': ingredient.amountPerPortion,
        'scaledAmount': scaledAmount,
        'unit': ingredient.unit,
        'ingredientCategory': ingredient.ingredientCategory,
        'portionCount': portionCount,
      }).timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removeMealIngredientFromShoppingList(
      MealModel meal, IngredientModel ingredient) async {
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
      }
    });
  }

  @override
  Future<List<MealModel>> getMealIngredientFromShoppingList() async {
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
  Future<void> restoreMealIngredientToShoppingList(
      MealModel meal, IngredientModel ingredient, int portionCount) async {
    return handleFirestoreException(() async {
      await addMealIngredientToShoppingList(meal, ingredient, portionCount);
    });
  }
}
