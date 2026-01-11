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

  Future<void> shareShoppingListWithFriend({
    required String friendUid,
    required List<ShoppingListMealIngredientModel> mealItemsToShare,
    required List<ShoppingListCustomItemModel> customItemsToShare,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not authenticated');

    final batch = _fs.batch();

    // --- 1) Meal ingredients (bez zmian) ---
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
          'ownerUid': friendUid,
          'sharedFromUid': user.uid,
          'sharedAt': FieldValue.serverTimestamp(),
          'isDeleted': false,
          'isSynced': true,
        },
        SetOptions(merge: true),
      );
    }

    // --- 2) Custom items (✅ NOWA LOGIKA jak w freezer) ---
    final friendCustomListRef =
        _fs.collection('Users').doc(friendUid).collection('CustomItems');

    final myCustomListRef =
        _fs.collection('Users').doc(user.uid).collection('CustomItems');

    for (final item in customItemsToShare) {
      if (item.isDeleted) continue;

      // fallback dla starszych danych bez metadanych
      final sourceOwnerUid = item.sourceOwnerUid.isNotEmpty ? item.sourceOwnerUid : user.uid;
      final sourceItemId = item.sourceItemId.isNotEmpty ? item.sourceItemId : item.customItemId;

      // ✅ jeśli wysyłasz do źródła (friend == sourceOwner) → nadpisz oryginał
      final isBackToSource = (friendUid == sourceOwnerUid);

      // doc u frienda:
      // - back-to-source: ID oryginału u źródła
      // - normal share: kopia unikalna, żeby nie mieszać z jego własnymi
      final targetDocId = isBackToSource ? sourceItemId : '${user.uid}_${item.customItemId}';

      final payload = <String, dynamic>{
        // trzymamy spójnie ID dokumentu
        'customItemId': targetDocId,
        'customItemName': item.customItemName,
        'customItemCategory': item.customItemCategory,
        'isDeleted': false,
        'isSynced': true,

        // dokument “leży u frienda”
        'ownerUid': friendUid,

        // metadane źródła
        'sourceOwnerUid': sourceOwnerUid,
        'sourceItemId': sourceItemId,

        // metadane share
        'sharedFromUid': user.uid,
        'sharedAt': FieldValue.serverTimestamp(),
      };

      // Dla kopii u frienda ustaw editors (żeby móc później “odesłać”)
      // (dla back-to-source celowo NIE ruszamy editors w źródle)
      if (!isBackToSource) {
        payload['editors'] = <String>[friendUid, user.uid];
      }

      batch.set(
        friendCustomListRef.doc(targetDocId),
        payload,
        SetOptions(merge: true),
      );

      // ✅ Jeśli udostępniasz SWÓJ ORYGINAŁ, dopisz friendUid do editors w Twoim oryginale
      final isMyOriginal = (sourceOwnerUid == user.uid && sourceItemId == item.customItemId);
      if (isMyOriginal) {
        batch.set(
          myCustomListRef.doc(item.customItemId),
          {
            'ownerUid': user.uid,
            'sourceOwnerUid': user.uid,
            'sourceItemId': item.customItemId,
            'isDeleted': false,
            'editors': FieldValue.arrayUnion(<String>[friendUid, user.uid]),
          },
          SetOptions(merge: true),
        );
      }
    }

    await batch.commit();
  }
}