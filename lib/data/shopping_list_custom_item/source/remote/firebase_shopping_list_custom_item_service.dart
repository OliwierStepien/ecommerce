import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

abstract class FirebaseShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList();
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> updateCustomItemToShoppingList(ShoppingListCustomItemModel item);
}

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

    return _firestore.collection('Users').doc(user.uid).collection('CustomItems');
  }

  Map<String, dynamic> _baseWithMeta(ShoppingListCustomItemModel item, String uid) {
    final base = item.toMap();

    final sourceOwnerUid =
        (base['sourceOwnerUid'] as String?)?.isNotEmpty == true ? base['sourceOwnerUid'] : uid;

    final sourceItemId =
        (base['sourceItemId'] as String?)?.isNotEmpty == true ? base['sourceItemId'] : item.customItemId;

    final editors = (base['editors'] is List && (base['editors'] as List).isNotEmpty)
        ? base['editors']
        : <String>[uid];

    return {
      ...base,
      'ownerUid': uid,
      'isDeleted': false,
      'sourceOwnerUid': sourceOwnerUid,
      'sourceItemId': sourceItemId,
      'editors': editors,
    };
  }

  @override
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _userCustomItemsCollection().doc(item.customItemId).set(
            _baseWithMeta(item, user.uid),
            SetOptions(merge: true),
          ).timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> updateCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _userCustomItemsCollection().doc(item.customItemId).set(
            _baseWithMeta(item, user.uid),
            SetOptions(merge: true),
          ).timeout(const Duration(seconds: 15));
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
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList() async {
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
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    return addCustomItemToShoppingList(item);
  }
}