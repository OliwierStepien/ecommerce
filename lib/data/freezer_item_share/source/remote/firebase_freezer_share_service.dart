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

  /// Udostępnia itemy do:
  /// Users/{friendUid}/FreezerItems/{docId}
  ///
  /// ✅ Jeśli friendUid == item.sourceOwnerUid -> "odsyłasz" do źródła,
  /// więc NADPISUJESZ oryginał: doc(item.sourceItemId)
  ///
  /// ✅ Jeśli normalny share -> tworzysz kopię u frienda: doc('${myUid}_${item.itemId}')
  Future<void> shareFreezerWithFriend({
    required String friendUid,
    required List<FreezerItemModel> itemsToShare,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not authenticated');

    final batch = _fs.batch();

    final friendFreezerRef =
        _fs.collection('Users').doc(friendUid).collection('FreezerItems');

    final myFreezerRef =
        _fs.collection('Users').doc(user.uid).collection('FreezerItems');

    for (final item in itemsToShare) {
      if (item.isDeleted) continue;

      // fallbacki gdyby starsze dane nie miały metadanych
      final sourceOwnerUid =
          item.sourceOwnerUid.isNotEmpty ? item.sourceOwnerUid : user.uid;
      final sourceItemId =
          item.sourceItemId.isNotEmpty ? item.sourceItemId : item.itemId;

      final isBackToSource = friendUid == sourceOwnerUid;

      // doc u frienda:
      // - back-to-source: nadpisz oryginał
      // - normal share: kopia unikalna
      final targetDocId = isBackToSource ? sourceItemId : '${user.uid}_${item.itemId}';

      // UWAGA: NIE bierz "base = item.toMap()" bez kontroli,
      // bo możesz nadpisać ownerUid/editors w niechciany sposób.
      final payload = <String, dynamic>{
        'itemId': targetDocId,
        'name': item.name,
        'category': item.category,
        'isDeleted': false,
        'isSynced': true,

        // dokument leży u frienda
        'ownerUid': friendUid,

        // metadane źródła
        'sourceOwnerUid': sourceOwnerUid,
        'sourceItemId': sourceItemId,

        // metadane share
        'sharedFromUid': user.uid,
        'sharedAt': FieldValue.serverTimestamp(),
      };

      // Dla kopii u frienda ustaw editors (na potrzeby uprawnień / późniejszych edycji)
      if (!isBackToSource) {
        payload['editors'] = <String>[friendUid, user.uid];
      }

      batch.set(
        friendFreezerRef.doc(targetDocId),
        payload,
        SetOptions(merge: true),
      );

      // ✅ jeśli to jest mój oryginał (źródło = ja), dopisz friendUid do editors w moim oryginale
      final isMyOriginal = sourceOwnerUid == user.uid && sourceItemId == item.itemId;
      if (isMyOriginal) {
        batch.set(
          myFreezerRef.doc(item.itemId),
          {
            'ownerUid': user.uid,
            'sourceOwnerUid': user.uid,
            'sourceItemId': item.itemId,
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