import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

abstract class FirebaseShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getCustomItemToShoppingList();
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item);
}

class FirebaseShoppingListCustomItemServiceImpl implements FirebaseShoppingListCustomItemService {
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

  @override
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    return handleFirestoreException(() async {
      await _userCustomItemsCollection()
          .doc(item.customItemId)
          .set(item.toMap())
          .timeout(const Duration(seconds: 15));
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
  Future<List<ShoppingListCustomItemModel>> getCustomItemToShoppingList() async {
    return handleFirestoreException(() async {
      final result = await _userCustomItemsCollection()
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));

      return result.docs.map((doc) => ShoppingListCustomItemModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    return addCustomItemToShoppingList(item);
  }
}