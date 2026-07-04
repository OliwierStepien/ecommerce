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
  Future<void> updateMealIngredientCheckedState(
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

  // ✅ UJEDNOLICONA ŚCIEŻKA z share i regułami
  CollectionReference<Map<String, dynamic>> _userShoppingMealItemsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();
    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('ShoppingListMealIngredients');
  }

  String _generateDocId(ShoppingListMealIngredientModel item) {
    return '${item.meal.mealId}_${item.ingredient.ingredientId}';
  }

  @override
  Future<void> addMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final docId = _generateDocId(item);
      final base = item.toFirestoreMap();

      // ✅ dopisz ownerUid, bo tego wymagają reguły "allow create"
      await _userShoppingMealItemsCollection()
          .doc(docId)
          .set({
            ...base,
            'ownerUid': user.uid,
            // Dla porządku upewnij się, że aktywny wpis:
            'isDeleted': false,
          })
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

      return result.docs
          .map((doc) => ShoppingListMealIngredientModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> restoreMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item) async {
    // przywracamy tak samo jak dodawanie
    return addMealIngredientToShoppingList(item);
  }

  @override
  Future<void> updateMealIngredientCheckedState(
      ShoppingListMealIngredientModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final docId = _generateDocId(item);

      // merge-set: gdy dokument nie istnieje (dodany offline), Firestore
      // potraktuje to jako create — reguły wymagają wtedy ownerUid == userId
      await _userShoppingMealItemsCollection()
          .doc(docId)
          .set(
            {
              'isChecked': item.isChecked,
              'ownerUid': user.uid,
            },
            SetOptions(merge: true),
          )
          .timeout(const Duration(seconds: 15));
    });
  }
}