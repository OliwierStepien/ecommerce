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

  FirebaseFreezerItemServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _col() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    return _firestore.collection('Users').doc(user.uid).collection('FreezerItems');
  }

  Map<String, dynamic> _baseWithMeta(FreezerItemModel item, String uid) {
    final base = item.toMap();

    // jeśli metadane puste, uzupełnij jako “moje”
    final sourceOwnerUid =
        (base['sourceOwnerUid'] as String?)?.isNotEmpty == true ? base['sourceOwnerUid'] : uid;
    final sourceItemId =
        (base['sourceItemId'] as String?)?.isNotEmpty == true ? base['sourceItemId'] : item.itemId;

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
  Future<void> add(FreezerItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _col().doc(item.itemId).set(
        _baseWithMeta(item, user.uid),
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> update(FreezerItemModel item) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _col().doc(item.itemId).set(
        _baseWithMeta(item, user.uid),
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
}