import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/freezer/model/freezer_item_model.dart';

abstract class FirebaseFreezerItemService {
  Future<void> add(FreezerItemModel item);
  Future<void> remove(String itemId);
  Future<void> update(FreezerItemModel item);
  Future<List<FreezerItemModel>> getAll();
}

class FirebaseFreezerItemServiceImpl implements FirebaseFreezerItemService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFreezerItemServiceImpl(
      {FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _col() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('FreezerItems');
  }

  @override
  Future<void> add(FreezerItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final base = item.toMap();
      await _col().doc(item.itemId).set(
        {
          ...base,
          'ownerUid': user.uid,
          'isDeleted': false,
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> remove(String itemId) async {
    return handleFirestoreException(() async {
      await _col().doc(itemId).delete().timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<FreezerItemModel>> getAll() async {
    return handleFirestoreException(() async {
      final res = await _col()
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));

      return res.docs.map((d) => FreezerItemModel.fromMap(d.data())).toList();
    });
  }

  @override
  Future<void> update(FreezerItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final base = item.toMap();

      await _col().doc(item.itemId).set(
        {
          ...base,
          'ownerUid': user.uid,
          'isDeleted': false,
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 15));
    });
  }
}
