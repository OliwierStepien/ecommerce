// data/friends/repository/friend_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/friends/mapper/friends_mapper.dart';
import 'package:mealapp/data/friends/source/remote/firebase_friend_service.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_invitation_entity.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FirebaseFriendService firebaseService;

  FriendRepositoryImpl({required this.firebaseService});

  @override
  Future<Either<Failure, List<FriendEntity>>> getFriends() async {
    debugLog('FriendRepository: Pobieranie listy znajomych');
    return handleFirestoreFailure(() async {
      final models = await firebaseService.getFriends();
      final entities = models.map(FriendMapper.toEntity).toList();
      debugLog('FriendRepository: Pobrano ${entities.length} znajomych');
      return entities;
    });
  }

  @override
  Future<Either<Failure, void>> addFriend(String friendEmail) async {
    debugLog('FriendRepository: Dodawanie znajomego: $friendEmail');
    return handleFirestoreFailure(() async {
      await firebaseService.addFriend(friendEmail);
      debugLog('FriendRepository: Pomyślnie dodano znajomego: $friendEmail');
    });
  }

  @override
  Future<Either<Failure, void>> removeFriend(String friendEmail) async {
    debugLog('FriendRepository: Usuwanie znajomego: $friendEmail');
    return handleFirestoreFailure(() async {
      await firebaseService.removeFriend(friendEmail);
      debugLog('FriendRepository: Pomyślnie usunięto znajomego: $friendEmail');
    });
  }

  @override
  Future<Either<Failure, void>> sendFriendInvitation(String friendEmail) async {
    debugLog('FriendRepository: Wysyłanie zaproszenia do: $friendEmail');
    return handleFirestoreFailure(() async {
      await firebaseService.sendFriendInvitation(friendEmail);
      debugLog('FriendRepository: Pomyślnie wysłano zaproszenie do: $friendEmail');
    });
  }

  @override
  Future<Either<Failure, List<FriendInvitationEntity>>> getPendingInvitations() async {
    debugLog('FriendRepository: Pobieranie oczekujących zaproszeń');
    return handleFirestoreFailure(() async {
      // Wywołaj debugowanie przed pobraniem
      await firebaseService.debugAllInvitations();
      
      final models = await firebaseService.getPendingInvitations();
      final entities = models.map(FriendMapper.invitationToEntity).toList();
      debugLog('FriendRepository: Pobrano ${entities.length} oczekujących zaproszeń');
      
      // Logowanie szczegółów każdego zaproszenia
      for (final entity in entities) {
        debugLog('FriendRepository: Zaproszenie ${entity.id}: ${entity.fromUserEmail} -> ${entity.toUserEmail}');
      }
      
      return entities;
    });
  }

  @override
  Future<Either<Failure, List<FriendInvitationEntity>>> getSentInvitations() async {
    debugLog('FriendRepository: Pobieranie wysłanych zaproszeń');
    return handleFirestoreFailure(() async {
      final models = await firebaseService.getSentInvitations();
      final entities = models.map(FriendMapper.invitationToEntity).toList();
      debugLog('FriendRepository: Pobrano ${entities.length} wysłanych zaproszeń');
      return entities;
    });
  }

  @override
  Future<Either<Failure, void>> respondToInvitation(String invitationId, bool accept) async {
    debugLog('FriendRepository: Odpowiadanie na zaproszenie: $invitationId, akceptacja: $accept');
    return handleFirestoreFailure(() async {
      await firebaseService.respondToInvitation(invitationId, accept);
      debugLog('FriendRepository: Pomyślnie przetworzono odpowiedź na zaproszenie: $invitationId');
    });
  }

  @override
  Future<Either<Failure, int>> getPendingInvitationsCount() async {
    debugLog('FriendRepository: Pobieranie liczby oczekujących zaproszeń');
    return handleFirestoreFailure(() async {
      final count = await firebaseService.getPendingInvitationsCount();
      debugLog('FriendRepository: Liczba oczekujących zaproszeń: $count');
      
      // Jeśli count jest 0, ale powinny być zaproszenia, zrób dodatkowe debugowanie
      if (count == 0) {
        debugLog('FriendRepository: UWAGA - liczba zaproszeń wynosi 0, sprawdzam wszystkie zaproszenia...');
        await firebaseService.debugAllInvitations();
      }
      
      return count;
    });
  }
}