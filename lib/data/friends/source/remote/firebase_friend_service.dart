// data/friends/source/firebase_friend_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/friends/model/friends_invitation_model.dart';
import 'package:mealapp/data/friends/model/friends_model.dart';

abstract class FirebaseFriendService {
  Future<List<FriendModel>> getFriends();
  Future<void> addFriend(String friendEmail);
  Future<void> removeFriend(String friendEmail);

  // Zaproszenia
  Future<void> sendFriendInvitation(String friendEmail);
  Future<List<FriendInvitationModel>> getPendingInvitations();
  Future<List<FriendInvitationModel>> getSentInvitations();
  Future<void> respondToInvitation(String invitationId, bool accept);
  Future<int> getPendingInvitationsCount();

  // DEV ONLY
  Future<void> debugAllInvitations();
}

class FirebaseFriendServiceImpl implements FirebaseFriendService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFriendServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId =>
      _auth.currentUser?.uid ?? (throw UnauthorizedException());

  String get _currentUserEmailLower =>
      _auth.currentUser?.email?.toLowerCase() ?? (throw UnauthorizedException());

  CollectionReference<Map<String, dynamic>> _userFriendsCollection(
      String userId) {
    return _firestore.collection('Users').doc(userId).collection('Friends');
  }

  CollectionReference<Map<String, dynamic>> get _invitationsCollection {
    return _firestore.collection('FriendInvitations');
  }

  @override
  Future<List<FriendModel>> getFriends() async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Pobieranie listy znajomych dla użytkownika: $_currentUserId');

      final returnedData = await _userFriendsCollection(_currentUserId).get();

      debugLog('FirebaseFriendService: Liczba dokumentów w kolekcji: ${returnedData.docs.length}');

      final List<FriendModel> friends = [];
      for (final doc in returnedData.docs) {
        final data = doc.data();

        String friendEmail = data['friendEmail'] as String;
        String friendName  = (data['friendName'] as String?) ?? 'Użytkownik';
        DateTime addedAt   = (data['addedAt'] as Timestamp).toDate();

        // ✅ spróbuj wziąć friendUid z dokumentu
        String friendUid   = (data['friendUid'] as String?) ?? '';

        // ✅ fallback dla starszych dokumentów: dociągnij UID po e-mailu
        if (friendUid.isEmpty) {
          try {
            final q = await _firestore
                .collection('Users')
                .where('email', isEqualTo: friendEmail)
                .limit(1)
                .get();
            if (q.docs.isNotEmpty) {
              friendUid = q.docs.first.id;
            }
          } catch (_) {
            // zostaw pusty; UI powinien radzić sobie (np. blokada share z info)
          }
        }

        friends.add(FriendModel(
          friendEmail: friendEmail,
          friendName: friendName,
          addedAt: addedAt,
          friendUid: friendUid,
        ));

        debugLog('FirebaseFriendService: Dok ${doc.id}: email=$friendEmail, uid=$friendUid');
      }

      debugLog('FirebaseFriendService: Znaleziono ${friends.length} znajomych');
      return friends;
    });
  }

  @override
  Future<void> addFriend(String friendEmail) async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Dodawanie znajomego: $friendEmail');

      final users = await _firestore
          .collection('Users')
          .where('email', isEqualTo: friendEmail)
          .limit(1)
          .get();

      if (users.docs.isEmpty) {
        debugLog('FirebaseFriendService: Użytkownik o emailu $friendEmail nie istnieje');
        throw Exception('Użytkownik o podanym emailu nie istnieje');
      }

      final friendUser = users.docs.first;
      final friendData = friendUser.data();
      final friendUserId = friendUser.id;

      debugLog('FirebaseFriendService: Znaleziono użytkownika: ${friendData['firstName']} (ID: $friendUserId)');

      // sprawdź duplikat po kluczu dokumentu = e-mail (zachowujemy kompatybilność z istniejącym schematem)
      final existingFriend = await _userFriendsCollection(_currentUserId).doc(friendEmail).get();
      if (existingFriend.exists) {
        debugLog('FirebaseFriendService: Użytkownik $friendEmail jest już znajomym');
        throw Exception('Ten użytkownik jest już Twoim znajomym');
      }

      final currentUserData = await _firestore.collection('Users').doc(_currentUserId).get();
      final currentUserName = currentUserData.data()?['firstName'] ?? 'Użytkownik';

      // ✅ zapis po STRONIE BIEŻĄCEGO UŻYTKOWNIKA (A): friendUid = UID znajomego
      final friendModelForCurrentUser = FriendModel(
        friendEmail: friendEmail,
        friendName: friendData['firstName'] ?? 'Użytkownik',
        addedAt: DateTime.now(),
        friendUid: friendUserId,
      );

      // ✅ zapis po STRONIE ZNAJOMEGO (B): friendUid = UID bieżącego użytkownika
      final friendModelForFriend = FriendModel(
        friendEmail: _currentUserEmailLower,
        friendName: currentUserName,
        addedAt: DateTime.now(),
        friendUid: _currentUserId,
      );

      debugLog('FirebaseFriendService: Dodawanie znajomych do obu użytkowników');

      // Dokumenty nadal podpisujemy e-mailem (jak wcześniej), ale w polu trzymamy UID
      await _userFriendsCollection(_currentUserId)
          .doc(friendEmail)
          .set(friendModelForCurrentUser.toMap());

      await _userFriendsCollection(friendUserId)
          .doc(_currentUserEmailLower)
          .set(friendModelForFriend.toMap());

      debugLog('FirebaseFriendService: Pomyślnie dodano znajomych (friendUid ustawione po obu stronach)');
    });
  }

  @override
  Future<void> removeFriend(String friendEmail) async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Usuwanie znajomego: $friendEmail');

      final users = await _firestore.collection('Users').where('email', isEqualTo: friendEmail).limit(1).get();
      if (users.docs.isNotEmpty) {
        final friendUserId = users.docs.first.id;

        final currentUserFriendDoc = await _userFriendsCollection(_currentUserId).doc(friendEmail).get();
        final friendUserFriendDoc  = await _userFriendsCollection(friendUserId).doc(_currentUserEmailLower).get();

        if (currentUserFriendDoc.exists) {
          await _userFriendsCollection(_currentUserId).doc(friendEmail).delete();
        }
        if (friendUserFriendDoc.exists) {
          await _userFriendsCollection(friendUserId).doc(_currentUserEmailLower).delete();
        }

        debugLog('FirebaseFriendService: Pomyślnie usunięto znajomego: $friendEmail');
      } else {
        debugLog('FirebaseFriendService: Nie znaleziono użytkownika o emailu: $friendEmail');
      }
    });
  }

  // --- pozostałe metody bez zmian funkcjonalnych ---
  @override
  Future<void> sendFriendInvitation(String friendEmail) async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Wysyłanie zaproszenia do: $friendEmail');

      final users = await _firestore.collection('Users').where('email', isEqualTo: friendEmail).limit(1).get();
      if (users.docs.isEmpty) {
        throw Exception('Użytkownik o podanym emailu nie istnieje');
      }

      final friendEmailLower = friendEmail.toLowerCase();
      if (friendEmailLower == _currentUserEmailLower) {
        throw Exception('Nie możesz dodać siebie jako znajomego');
      }

      final existingFriend = await _userFriendsCollection(_currentUserId).doc(friendEmail).get();
      if (existingFriend.exists) {
        throw Exception('Ten użytkownik jest już Twoim znajomym');
      }

      final existingInvitation = await _invitationsCollection
          .where('fromUserEmail', isEqualTo: _currentUserEmailLower)
          .where('toUserEmail', isEqualTo: friendEmailLower)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingInvitation.docs.isNotEmpty) {
        throw Exception('Zaproszenie zostało już wysłane do tego użytkownika');
      }

      final currentUserData = await _firestore.collection('Users').doc(_currentUserId).get();
      final currentUserName = currentUserData.data()?['firstName'] ?? 'Użytkownik';

      final invitation = FriendInvitationModel(
        id: _invitationsCollection.doc().id,
        fromUserEmail: _currentUserEmailLower,
        fromUserName: currentUserName,
        toUserEmail: friendEmailLower,
        sentAt: DateTime.now(),
        status: FriendInvitationStatus.pending,
      );

      await _invitationsCollection.doc(invitation.id).set(invitation.toMap());
      debugLog('FirebaseFriendService: Zaproszenie pomyślnie wysłane do $friendEmailLower');
    });
  }

  @override
  Future<List<FriendInvitationModel>> getPendingInvitations() async {
    return handleFirestoreException(() async {
      final invitations = await _invitationsCollection
          .where('toUserEmail', isEqualTo: _currentUserEmailLower)
          .where('status', isEqualTo: 'pending')
          .orderBy('sentAt', descending: true)
          .get();

      return invitations.docs.map((doc) => FriendInvitationModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<List<FriendInvitationModel>> getSentInvitations() async {
    return handleFirestoreException(() async {
      final invitations = await _invitationsCollection
          .where('fromUserEmail', isEqualTo: _currentUserEmailLower)
          .orderBy('sentAt', descending: true)
          .get();

      return invitations.docs.map((doc) => FriendInvitationModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> respondToInvitation(String invitationId, bool accept) async {
    return handleFirestoreException(() async {
      final invitationDoc = await _invitationsCollection.doc(invitationId).get();
      if (!invitationDoc.exists) throw Exception('Zaproszenie nie istnieje');

      final invitation = FriendInvitationModel.fromMap(invitationDoc.data()!);

      if (invitation.toUserEmail.toLowerCase() != _currentUserEmailLower) {
        throw Exception('Nie masz uprawnień do tej operacji');
      }

      final newStatus = accept ? FriendInvitationStatus.accepted : FriendInvitationStatus.rejected;
      await _invitationsCollection.doc(invitationId).update({'status': newStatus.toString().split('.').last});

      if (accept) {
        await addFriend(invitation.fromUserEmail);
      }
    });
  }

  @override
  Future<int> getPendingInvitationsCount() async {
    return handleFirestoreException(() async {
      final invitations = await _invitationsCollection
          .where('toUserEmail', isEqualTo: _currentUserEmailLower)
          .where('status', isEqualTo: 'pending')
          .get();

      return invitations.docs.length;
    });
  }

  @override
  Future<void> debugAllInvitations() async {
    try {
      final allInvitations = await _invitationsCollection
          .where('toUserEmail', isEqualTo: _currentUserEmailLower)
          .get();
      debugLog('=== DEBUG: INV dla mnie (${allInvitations.docs.length}) ===');
      for (final doc in allInvitations.docs) {
        final data = doc.data();
        debugLog('INV ${doc.id}: ${data['fromUserEmail']} -> ${data['toUserEmail']} [${data['status']}]');
      }
      debugLog('=== KONIEC DEBUG ===');
    } catch (e) {
      debugLog('FirebaseFriendService: Błąd debugowania zaproszeń: $e');
    }
  }
}