import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';

class FirebaseShoppingListShareService {
  final FirebaseFirestore _fs;
  final FirebaseAuth _auth;

  FirebaseShoppingListShareService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _fs = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Kopiuje **aktywne** (isDeleted=false) pozycje listy zakupów nadawcy
  /// do kolekcji odbiorcy:
  ///
  /// - Users/{friendUid}/ShoppingListMealIngredients/{mealId_ingredientId}
  /// - Users/{friendUid}/CustomItems/{customItemId}
  Future<void> shareShoppingListWithFriend({
    required String friendUid,
    required List<ShoppingListMealIngredientModel> mealItemsToShare,
    required List<ShoppingListCustomItemModel> customItemsToShare,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not authenticated');
    }

    final batch = _fs.batch();

    // --- 1) Składniki z posiłków ---
    final friendMealListRef = _fs
        .collection('Users')
        .doc(friendUid)
        .collection('ShoppingListMealIngredients');

    for (final item in mealItemsToShare) {
      final docId = '${item.meal.mealId}_${item.ingredient.ingredientId}';
      final base = item.toFirestoreMap();

      batch.set(
        friendMealListRef.doc(docId),
        {
          ...base,

          // 🔐 kluczowe pod reguły (allow create sprawdza ownerUid == userId)
          'ownerUid': friendUid,

          // metadane udostępnienia
          'sharedFromUid': user.uid,
          'sharedAt': FieldValue.serverTimestamp(),

          // po stronie odbiorcy traktujemy wpis jako aktywny i zsynchronizowany
          'isDeleted': false,
          'isSynced': true,
        },
        SetOptions(merge: true),
      );
    }

    // --- 2) Własne produkty (CustomItems) ---
    final friendCustomListRef =
        _fs.collection('Users').doc(friendUid).collection('CustomItems');

    for (final item in customItemsToShare) {
      final docId = item.customItemId;
      final base = item.toMap();

      batch.set(
        friendCustomListRef.doc(docId),
        {
          ...base,

          // 🔐 analogicznie – ownerUid = friendUid pod reguły
          'ownerUid': friendUid,

          // metadane udostępnienia
          'sharedFromUid': user.uid,
          'sharedAt': FieldValue.serverTimestamp(),

          // po stronie odbiorcy traktujemy wpis jako aktywny
          'isDeleted': false,
          // isSynced pomocniczo – jeśli kiedyś będziesz je zaciągać do Hive
          'isSynced': true,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}