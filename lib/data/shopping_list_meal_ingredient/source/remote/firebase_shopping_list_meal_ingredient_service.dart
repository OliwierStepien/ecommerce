import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';

abstract class FirebaseShoppingListMealIngredientService {
  Future<void> addMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item);
  Future<void> removeMealIngredientFromShoppingList(
      ShoppingListMealIngredientModel item);
  Future<List<ShoppingListMealIngredientModel>>
      getMealIngredientsFromShoppingList();
  Future<void> restoreMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item);
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

  String _generateDocId(ShoppingListMealIngredientModel item) {
    return '${item.meal.mealId}_${item.ingredient.ingredientId}';
  }

  @override
  Future<void> addMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item) async {
    return handleFirestoreException(() async {
      final docId = _generateDocId(item);
      await _userShoppingMealItemsCollection()
          .doc(docId)
          .set(item.toMap())
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removeMealIngredientFromShoppingList(
      ShoppingListMealIngredientModel item) async {
    return handleFirestoreException(() async {
      final docId = _generateDocId(item);
      await _userShoppingMealItemsCollection()
          .doc(docId)
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getMealIngredientsFromShoppingList() async {
    return handleFirestoreException(() async {
      final result = await _userShoppingMealItemsCollection()
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));

      return result.docs.map((doc) {
        return ShoppingListMealIngredientModel.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<void> restoreMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item) async {
    return addMealIngredientToShoppingList(item);
  }
}
