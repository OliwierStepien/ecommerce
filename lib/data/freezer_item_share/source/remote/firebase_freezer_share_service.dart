import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/data/freezer/model/freezer_item_model.dart';

class FirebaseFreezerShareService {
  final FirebaseFirestore _fs;
  final FirebaseAuth _auth;

  FirebaseFreezerShareService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _fs = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Kopiuje aktywne pozycje zamrażarki nadawcy do subkolekcji odbiorcy:
  /// Users/{friendUid}/FreezerItems/{itemId}
  Future<void> shareFreezerWithFriend({
    required String friendUid,
    required List<FreezerItemModel> itemsToShare,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not authenticated');

    final batch = _fs.batch();

    final friendFreezerRef =
        _fs.collection('Users').doc(friendUid).collection('FreezerItems');

    for (final item in itemsToShare) {
      final docId = item.itemId;
      final base = item.toMap();

      batch.set(
        friendFreezerRef.doc(docId),
        {
          ...base,

          // 🔐 pod rules
          'ownerUid': friendUid,

          // metadane udostępnienia
          'sharedFromUid': user.uid,
          'sharedAt': FieldValue.serverTimestamp(),

          // po stronie odbiorcy zawsze aktywne i "zsynchronizowane"
          'isDeleted': false,
          'isSynced': true,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}