// data/friends/source/firebase_friend_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/friends/model/friends_model.dart';

abstract class FirebaseFriendService {
  Future<List<FriendModel>> getFriends();
  Future<void> addFriend(String friendEmail);
  Future<void> removeFriend(String friendEmail);
}

class FirebaseFriendServiceImpl implements FirebaseFriendService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFriendServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userFriendsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Friends');
  }

  @override
  Future<List<FriendModel>> getFriends() async {
    return handleFirestoreException(() async {
      final returnedData = await _userFriendsCollection().get();
      return returnedData.docs
          .map((doc) => FriendModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addFriend(String friendEmail) async {
    return handleFirestoreException(() async {
      // Najpierw znajdź użytkownika po emailu
      final users = await _firestore
          .collection('Users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (users.docs.isEmpty) {
        throw Exception('Użytkownik o podanym emailu nie istnieje');
      }

      final friendUser = users.docs.first;
      final friendData = friendUser.data();

      final friendModel = FriendModel(
        friendEmail: friendEmail,
        friendName: friendData['firstName'] ?? 'Użytkownik',
        addedAt: DateTime.now(),
      );

      await _userFriendsCollection()
          .doc(friendEmail) // Używamy emaila jako ID dokumentu
          .set(friendModel.toMap());
    });
  }

  @override
  Future<void> removeFriend(String friendEmail) async {
    return handleFirestoreException(() async {
      await _userFriendsCollection()
          .doc(friendEmail)
          .delete();
    });
  }
}