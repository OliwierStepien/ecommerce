import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

// Interfejs (abstrakcja) definiujący kontrakt dla serwisu obsługującego custom itemy w liście zakupów.
abstract class FirebaseShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList();
  Future<void> restoreCustomItemToShoppingList(
      ShoppingListCustomItemModel item);
  Future<void> updateCustomItemToShoppingList(ShoppingListCustomItemModel item);
}

// Implementacja interfejsu - korzysta z Firebase Firestore oraz Firebase Auth.
class FirebaseShoppingListCustomItemServiceImpl
    implements FirebaseShoppingListCustomItemService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseShoppingListCustomItemServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userCustomItemsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('CustomItems');
  }

  @override
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final base = item.toMap();

      await _userCustomItemsCollection().doc(item.customItemId).set({
        ...base,
        'ownerUid': user.uid,
        'isDeleted': false,
      }).timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removeCustomItemFromShoppingList(String customItemId) async {
    return handleFirestoreException(() async {
      await _userCustomItemsCollection()
          .doc(customItemId)
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getCustomItemFromShoppingList() async {
    return handleFirestoreException(() async {
      final result = await _userCustomItemsCollection()
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));

      return result.docs
          .map((doc) => ShoppingListCustomItemModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> restoreCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    return addCustomItemToShoppingList(item);
  }

  @override
  Future<void> updateCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final base = item.toMap();

      await _userCustomItemsCollection().doc(item.customItemId).set(
        {
          ...base,
          'ownerUid': user.uid,
          'isDeleted': false,
        },
        SetOptions(merge: true), // ⬅️ kluczowe
      ).timeout(const Duration(seconds: 15));
    });
  }
}
