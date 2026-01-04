import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';

abstract class FirebaseShoppingListClearService {
  Future<void> clearAllForCurrentUser();
}

/// Czyści CAŁĄ listę zakupów użytkownika w Firestore:
/// - Users/{uid}/ShoppingListMealIngredients
/// - Users/{uid}/CustomItems
///
/// Implementacja robi batch delete w paczkach (Firestore limit 500 operacji / batch).
class FirebaseShoppingListClearServiceImpl
    implements FirebaseShoppingListClearService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseShoppingListClearServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> clearAllForCurrentUser() async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final mealCol = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('ShoppingListMealIngredients');

      final customCol = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('CustomItems');

      // skasuj oba zbiory
      await _deleteWholeCollection(mealCol);
      await _deleteWholeCollection(customCol);
    });
  }

  Future<void> _deleteWholeCollection(
    CollectionReference<Map<String, dynamic>> col,
  ) async {
    // Firestore batch limit = 500 operacji
    const int batchLimit = 450;

    while (true) {
      final snap = await col.limit(batchLimit).get();
      if (snap.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}