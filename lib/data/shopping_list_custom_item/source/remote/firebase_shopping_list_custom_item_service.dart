import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

abstract class FirebaseShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel shoppingListCustomItemModel);
  Future<void> removeCustomItemFromShoppingList(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getCustomItemToShoppingList();
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

  @override
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel shoppingListCustomItemModel) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('CustomItems')
          .doc(shoppingListCustomItemModel.customItemId)
          .set(shoppingListCustomItemModel.toMap())
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removeCustomItemFromShoppingList(String customItemId) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('CustomItems')
          .doc(customItemId)
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getCustomItemToShoppingList() async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();
      final returnedData = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('CustomItems')
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs
          .map((doc) => ShoppingListCustomItemModel.fromMap(doc.data()))
          .toList();
    });
  }
}
