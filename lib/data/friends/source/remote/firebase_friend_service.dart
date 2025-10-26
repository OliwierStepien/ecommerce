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

  // Nowe metody dla zaproszeń
  Future<void> sendFriendInvitation(String friendEmail);
  Future<List<FriendInvitationModel>> getPendingInvitations();
  Future<List<FriendInvitationModel>> getSentInvitations();
  Future<void> respondToInvitation(String invitationId, bool accept);
  Future<int> getPendingInvitationsCount();
  Future<void> debugAllInvitations(); // Dodana metoda debugowania
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

  String get _currentUserEmail =>
      _auth.currentUser?.email ?? (throw UnauthorizedException());

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
      debugLog(
          'FirebaseFriendService: Pobieranie listy znajomych dla użytkownika: $_currentUserId');

      final returnedData = await _userFriendsCollection(_currentUserId).get();

      // DODAJ TE LOGI:
      debugLog(
          'FirebaseFriendService: Liczba dokumentów w kolekcji: ${returnedData.docs.length}');

      for (final doc in returnedData.docs) {
        debugLog('FirebaseFriendService: Dokument ${doc.id}: ${doc.data()}');
      }

      final friends = returnedData.docs
          .map((doc) => FriendModel.fromMap(doc.data()))
          .toList();

      debugLog('FirebaseFriendService: Znaleziono ${friends.length} znajomych');
      return friends;
    });
  }

  @override
  Future<void> addFriend(String friendEmail) async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Dodawanie znajomego: $friendEmail');

      // Znajdź użytkownika po emailu
      debugLog(
          'FirebaseFriendService: Szukanie użytkownika po emailu: $friendEmail');
      final users = await _firestore
          .collection('Users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (users.docs.isEmpty) {
        debugLog(
            'FirebaseFriendService: Użytkownik o emailu $friendEmail nie istnieje');
        throw Exception('Użytkownik o podanym emailu nie istnieje');
      }

      final friendUser = users.docs.first;
      final friendData = friendUser.data();
      final friendUserId = friendUser.id;
      debugLog(
          'FirebaseFriendService: Znaleziono użytkownika: ${friendData['firstName']} (ID: $friendUserId)');

      // Sprawdź czy już jesteście znajomymi
      final existingFriend =
          await _userFriendsCollection(_currentUserId).doc(friendEmail).get();

      if (existingFriend.exists) {
        debugLog(
            'FirebaseFriendService: Użytkownik $friendEmail jest już znajomym');
        throw Exception('Ten użytkownik jest już Twoim znajomym');
      }

      // Stwórz model znajomego dla obecnego użytkownika
      final friendModelForCurrentUser = FriendModel(
        friendEmail: friendEmail,
        friendName: friendData['firstName'] ?? 'Użytkownik',
        addedAt: DateTime.now(),
      );

      // Stwórz model znajomego dla drugiego użytkownika
      final currentUserData =
          await _firestore.collection('Users').doc(_currentUserId).get();

      final currentUserName =
          currentUserData.data()?['firstName'] ?? 'Użytkownik';
      final friendModelForFriend = FriendModel(
        friendEmail: _currentUserEmail,
        friendName: currentUserName,
        addedAt: DateTime.now(),
      );

      debugLog(
          'FirebaseFriendService: Dodawanie znajomych do obu użytkowników');

      // Dodaj znajomych dla obu użytkowników
      await _userFriendsCollection(_currentUserId)
          .doc(friendEmail)
          .set(friendModelForCurrentUser.toMap());

      await _userFriendsCollection(friendUserId)
          .doc(_currentUserEmail)
          .set(friendModelForFriend.toMap());

      debugLog(
          'FirebaseFriendService: Pomyślnie dodano znajomych - $_currentUserEmail i $friendEmail są teraz znajomymi');
    });
  }

  @override
  Future<void> removeFriend(String friendEmail) async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Usuwanie znajomego: $friendEmail');

      // Znajdź ID znajomego
      final users = await _firestore
          .collection('Users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (users.docs.isNotEmpty) {
        final friendUserId = users.docs.first.id;
        debugLog(
            'FirebaseFriendService: Znaleziono ID znajomego: $friendUserId');

        // DODATKOWE LOGOWANIE PRZED USUNIĘCIEM
        debugLog(
            'FirebaseFriendService: Sprawdzanie istnienia dokumentów przed usunięciem...');

        final currentUserFriendDoc =
            await _userFriendsCollection(_currentUserId).doc(friendEmail).get();

        final friendUserFriendDoc = await _userFriendsCollection(friendUserId)
            .doc(_currentUserEmail)
            .get();

        debugLog(
            'FirebaseFriendService: Dokument obecnego użytkownika istnieje: ${currentUserFriendDoc.exists}');
        debugLog(
            'FirebaseFriendService: Dokument znajomego istnieje: ${friendUserFriendDoc.exists}');

        // Usuń z listy znajomych obu użytkowników
        if (currentUserFriendDoc.exists) {
          await _userFriendsCollection(_currentUserId)
              .doc(friendEmail)
              .delete();
          debugLog(
              'FirebaseFriendService: Usunięto dokument z kolekcji obecnego użytkownika');
        }

        if (friendUserFriendDoc.exists) {
          await _userFriendsCollection(friendUserId)
              .doc(_currentUserEmail)
              .delete();
          debugLog(
              'FirebaseFriendService: Usunięto dokument z kolekcji znajomego');
        }

        debugLog(
            'FirebaseFriendService: Pomyślnie usunięto znajomego: $friendEmail');

        // DODATKOWE: SPRAWDŹ CZY DOKUMENTY ZOSTAŁY USUNIĘTE
        final checkCurrentUser =
            await _userFriendsCollection(_currentUserId).doc(friendEmail).get();
        final checkFriendUser = await _userFriendsCollection(friendUserId)
            .doc(_currentUserEmail)
            .get();

        debugLog(
            'FirebaseFriendService: PO USUNIĘCIU - dokument obecnego użytkownika istnieje: ${checkCurrentUser.exists}');
        debugLog(
            'FirebaseFriendService: PO USUNIĘCIU - dokument znajomego istnieje: ${checkFriendUser.exists}');
      } else {
        debugLog(
            'FirebaseFriendService: Nie znaleziono użytkownika o emailu: $friendEmail');
      }
    });
  }

  @override
  Future<void> sendFriendInvitation(String friendEmail) async {
    return handleFirestoreException(() async {
      debugLog('FirebaseFriendService: Wysyłanie zaproszenia do: $friendEmail');

      // Sprawdź czy użytkownik istnieje
      debugLog(
          'FirebaseFriendService: Sprawdzanie istnienia użytkownika: $friendEmail');
      final users = await _firestore
          .collection('Users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (users.docs.isEmpty) {
        debugLog('FirebaseFriendService: Użytkownik $friendEmail nie istnieje');
        throw Exception('Użytkownik o podanym emailu nie istnieje');
      }

      // Sprawdź czy nie wysyłasz do siebie
      if (friendEmail == _currentUserEmail) {
        debugLog('FirebaseFriendService: Próba wysłania zaproszenia do siebie');
        throw Exception('Nie możesz dodać siebie jako znajomego');
      }

      // Sprawdź czy już jesteście znajomymi
      final existingFriend =
          await _userFriendsCollection(_currentUserId).doc(friendEmail).get();

      if (existingFriend.exists) {
        debugLog(
            'FirebaseFriendService: Użytkownik $friendEmail jest już znajomym');
        throw Exception('Ten użytkownik jest już Twoim znajomym');
      }

      // Sprawdź czy już istnieje zaproszenie
      debugLog('FirebaseFriendService: Sprawdzanie istniejących zaproszeń');
      final existingInvitation = await _invitationsCollection
          .where('fromUserEmail', isEqualTo: _currentUserEmail)
          .where('toUserEmail', isEqualTo: friendEmail)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingInvitation.docs.isNotEmpty) {
        debugLog(
            'FirebaseFriendService: Istnieje już aktywne zaproszenie do $friendEmail');
        throw Exception('Zaproszenie zostało już wysłane do tego użytkownika');
      }

      // Pobierz dane obecnego użytkownika
      final currentUserData =
          await _firestore.collection('Users').doc(_currentUserId).get();

      final currentUserName =
          currentUserData.data()?['firstName'] ?? 'Użytkownik';

      final invitation = FriendInvitationModel(
        id: _invitationsCollection.doc().id,
        fromUserEmail: _currentUserEmail,
        fromUserName: currentUserName,
        toUserEmail: friendEmail,
        sentAt: DateTime.now(),
        status: FriendInvitationStatus.pending,
      );

      debugLog(
          'FirebaseFriendService: Tworzenie zaproszenia ID: ${invitation.id}');
      debugLog(
          'FirebaseFriendService: Od: $_currentUserEmail ($currentUserName)');
      debugLog('FirebaseFriendService: Do: $friendEmail');

      await _invitationsCollection.doc(invitation.id).set(invitation.toMap());

      debugLog(
          'FirebaseFriendService: Zaproszenie pomyślnie wysłane do $friendEmail');
    });
  }

  @override
  Future<List<FriendInvitationModel>> getPendingInvitations() async {
    return handleFirestoreException(() async {
      debugLog(
          'FirebaseFriendService: Pobieranie oczekujących zaproszeń dla: $_currentUserEmail');

      try {
        debugLog('FirebaseFriendService: Wykonuję zapytanie do Firestore...');
        final invitations = await _invitationsCollection
            .where('toUserEmail', isEqualTo: _currentUserEmail)
            .where('status', isEqualTo: 'pending')
            .orderBy('sentAt', descending: true)
            .get();

        debugLog(
            'FirebaseFriendService: Zapytanie zwróciło ${invitations.docs.length} dokumentów');

        // Dodatkowe logowanie każdego znalezionego dokumentu
        for (final doc in invitations.docs) {
          final data = doc.data();
          debugLog('FirebaseFriendService: Dokument ${doc.id}:');
          debugLog('  - fromUserEmail: ${data['fromUserEmail']}');
          debugLog('  - toUserEmail: ${data['toUserEmail']}');
          debugLog('  - status: ${data['status']}');
          debugLog('  - sentAt: ${data['sentAt']}');
        }

        final pendingInvitations = invitations.docs.map((doc) {
          try {
            return FriendInvitationModel.fromMap(doc.data());
          } catch (e) {
            debugLog(
                'FirebaseFriendService: Błąd parsowania dokumentu ${doc.id}: $e');
            debugLog('FirebaseFriendService: Dane dokumentu: ${doc.data()}');
            rethrow;
          }
        }).toList();

        debugLog(
            'FirebaseFriendService: Znaleziono ${pendingInvitations.length} oczekujących zaproszeń');
        return pendingInvitations;
      } catch (e) {
        debugLog('FirebaseFriendService: BŁĄD pobierania zaproszeń: $e');
        debugLog('FirebaseFriendService: Stack trace: ${e.toString()}');
        return [];
      }
    });
  }

  @override
  Future<List<FriendInvitationModel>> getSentInvitations() async {
    return handleFirestoreException(() async {
      debugLog(
          'FirebaseFriendService: Pobieranie wysłanych zaproszeń przez: $_currentUserEmail');

      try {
        final invitations = await _invitationsCollection
            .where('fromUserEmail', isEqualTo: _currentUserEmail)
            .orderBy('sentAt', descending: true)
            .get();

        final sentInvitations = invitations.docs
            .map((doc) => FriendInvitationModel.fromMap(doc.data()))
            .toList();

        debugLog(
            'FirebaseFriendService: Znaleziono ${sentInvitations.length} wysłanych zaproszeń');
        return sentInvitations;
      } catch (e) {
        debugLog(
            'FirebaseFriendService: Błąd pobierania wysłanych zaproszeń: $e');
        return [];
      }
    });
  }

  @override
  Future<void> respondToInvitation(String invitationId, bool accept) async {
    return handleFirestoreException(() async {
      debugLog(
          'FirebaseFriendService: Odpowiadanie na zaproszenie ID: $invitationId, akceptacja: $accept');

      final invitationDoc =
          await _invitationsCollection.doc(invitationId).get();

      if (!invitationDoc.exists) {
        debugLog(
            'FirebaseFriendService: Zaproszenie $invitationId nie istnieje');
        throw Exception('Zaproszenie nie istnieje');
      }

      final invitation = FriendInvitationModel.fromMap(invitationDoc.data()!);
      debugLog(
          'FirebaseFriendService: Znaleziono zaproszenie od: ${invitation.fromUserEmail}');

      if (invitation.toUserEmail != _currentUserEmail) {
        debugLog(
            'FirebaseFriendService: Brak uprawnień - zaproszenie jest dla: ${invitation.toUserEmail}, a użytkownik to: $_currentUserEmail');
        throw Exception('Nie masz uprawnień do tej operacji');
      }

      final newStatus = accept
          ? FriendInvitationStatus.accepted
          : FriendInvitationStatus.rejected;

      debugLog(
          'FirebaseFriendService: Aktualizacja statusu zaproszenia na: $newStatus');

      // Aktualizuj status zaproszenia
      await _invitationsCollection
          .doc(invitationId)
          .update({'status': newStatus.toString().split('.').last});

      // Jeśli zaakceptowano, dodaj znajomych
      if (accept) {
        debugLog(
            'FirebaseFriendService: Akceptacja zaproszenia - dodawanie znajomego: ${invitation.fromUserEmail}');
        await addFriend(invitation.fromUserEmail);
      } else {
        debugLog(
            'FirebaseFriendService: Odrzucenie zaproszenia od: ${invitation.fromUserEmail}');
      }

      debugLog(
          'FirebaseFriendService: Pomyślnie przetworzono odpowiedź na zaproszenie');
    });
  }

  @override
  Future<int> getPendingInvitationsCount() async {
    return handleFirestoreException(() async {
      debugLog(
          'FirebaseFriendService: Pobieranie liczby oczekujących zaproszeń dla: $_currentUserEmail');

      try {
        debugLog(
            'FirebaseFriendService: Wykonuję zapytanie count do Firestore...');
        final invitations = await _invitationsCollection
            .where('toUserEmail', isEqualTo: _currentUserEmail)
            .where('status', isEqualTo: 'pending')
            .get();

        debugLog(
            'FirebaseFriendService: Zapytanie count zwróciło ${invitations.docs.length} dokumentów');

        // Logowanie szczegółów dla debugowania
        for (final doc in invitations.docs) {
          final data = doc.data();
          debugLog(
              'FirebaseFriendService: Count - Dokument ${doc.id}: ${data['fromUserEmail']} -> ${data['toUserEmail']}');
        }

        final count = invitations.docs.length;
        debugLog(
            'FirebaseFriendService: Liczba oczekujących zaproszeń: $count');
        return count;
      } catch (e) {
        debugLog('FirebaseFriendService: BŁĄD pobierania liczby zaproszeń: $e');
        debugLog('FirebaseFriendService: Stack trace: ${e.toString()}');
        return 0;
      }
    });
  }

  @override
  Future<void> debugAllInvitations() async {
    try {
      debugLog('=== DEBUG: WSZYSTKIE ZAPROSZENIA W FIRESTORE ===');

      final allInvitations = await _invitationsCollection.get();
      debugLog(
          'FirebaseFriendService: Całkowita liczba zaproszeń w Firestore: ${allInvitations.docs.length}');

      for (final doc in allInvitations.docs) {
        final data = doc.data();
        debugLog('FirebaseFriendService: Zaproszenie ${doc.id}:');
        debugLog('  - Od: ${data['fromUserEmail']}');
        debugLog('  - Do: ${data['toUserEmail']}');
        debugLog('  - Status: ${data['status']}');
        debugLog('  - Data: ${data['sentAt']}');
        debugLog('  - ID: ${doc.id}');
      }

      debugLog('=== KONIEC DEBUG ===');
    } catch (e) {
      debugLog('FirebaseFriendService: Błąd debugowania zaproszeń: $e');
    }
  }
}
