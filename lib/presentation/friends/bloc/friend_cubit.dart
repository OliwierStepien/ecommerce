// presentation/user_info/bloc/friends_cubit.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/usecase/add_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_pending_invitations_usecase.dart';
import 'package:mealapp/domain/friends/usecase/remove_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/respond_to_invitation_usecase.dart';
import 'package:mealapp/domain/friends/usecase/send_friend_invitation_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_pending_invitations_count_usecase.dart';
import 'package:mealapp/presentation/friends/bloc/friend_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final GetFriendsUseCase getFriendsUseCase;
  final AddFriendUseCase addFriendUseCase;
  final RemoveFriendUseCase removeFriendUseCase;
  final SendFriendInvitationUseCase sendFriendInvitationUseCase;
  final GetPendingInvitationsUseCase getPendingInvitationsUseCase;
  final RespondToInvitationUseCase respondToInvitationUseCase;
  final GetPendingInvitationsCountUseCase getPendingInvitationsCountUseCase;

  FriendsCubit({
    required this.getFriendsUseCase,
    required this.addFriendUseCase,
    required this.removeFriendUseCase,
    required this.sendFriendInvitationUseCase,
    required this.getPendingInvitationsUseCase,
    required this.respondToInvitationUseCase,
    required this.getPendingInvitationsCountUseCase,
  }) : super(FriendsInitial());

  Future<void> initializeFriendsData() async {
    debugLog('FriendsCubit: Inicjalizacja wszystkich danych znajomych');
    emit(FriendsLoading());

    // Równoległe ładowanie wszystkich danych
    await Future.wait([
      loadFriends(),
      loadPendingInvitations(),
      loadPendingInvitationsCount(),
    ]);
  }

  Future<void> loadFriends() async {
    debugLog('FriendsCubit: Ładowanie listy znajomych');
    emit(FriendsLoading());

    final result = await getFriendsUseCase.call(NoParams());

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd ładowania znajomych: ${mapFailureToMessage(failure)}');
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (friends) {
        debugLog(
            'FriendsCubit: Pomyślnie załadowano ${friends.length} znajomych');
        emit(FriendsLoaded(
          friends: friends,
          pendingInvitations: state.pendingInvitations,
          invitationsCount: state.invitationsCount,
        ));
      },
    );
  }

  Future<void> addFriend(String email) async {
    debugLog('FriendsCubit: Dodawanie znajomego: $email');
    final result = await addFriendUseCase.call(email);

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd dodawania znajomego: ${mapFailureToMessage(failure)}');
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (_) {
        debugLog(
            'FriendsCubit: Pomyślnie dodano znajomego - odświeżanie listy');
        loadFriends();
      },
    );
  }

  Future<void> removeFriend(String friendEmail) async {
    debugLog('FriendsCubit: Usuwanie znajomego: $friendEmail');
    final result = await removeFriendUseCase.call(friendEmail);

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd usuwania znajomego: ${mapFailureToMessage(failure)}');
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (_) {
        debugLog(
            'FriendsCubit: Pomyślnie usunięto znajomego - odświeżanie listy');
        loadFriends();
      },
    );
  }

  Future<void> sendFriendInvitation(String email) async {
    debugLog('FriendsCubit: Wysyłanie zaproszenia do: $email');
    final result = await sendFriendInvitationUseCase.call(email);

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd wysyłania zaproszenia: ${mapFailureToMessage(failure)}');
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (_) {
        debugLog(
            'FriendsCubit: Pomyślnie wysłano zaproszenie - odświeżanie listy');
        loadFriends();
      },
    );
  }

  Future<void> loadPendingInvitations() async {
    debugLog('FriendsCubit: Ładowanie oczekujących zaproszeń');
    debugLog(
        'FriendsCubit: Aktualny użytkownik powinien widzieć zaproszenia do: ${_getCurrentUserEmail()}');

    final result = await getPendingInvitationsUseCase.call(NoParams());

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd ładowania zaproszeń: ${mapFailureToMessage(failure)}');
      },
      (invitations) {
        debugLog(
            'FriendsCubit: Pomyślnie załadowano ${invitations.length} zaproszeń');

        // Dodatkowe logowanie
        if (invitations.isEmpty) {
          debugLog('FriendsCubit: UWAGA - lista zaproszeń jest PUSTA!');
          debugLog(
              'FriendsCubit: Sprawdzam czy użytkownik ma jakieś zaproszenia...');
        } else {
          for (final invitation in invitations) {
            debugLog(
                'FriendsCubit: Zaproszenie: ${invitation.fromUserName} (${invitation.fromUserEmail})');
          }
        }

        if (state is FriendsLoaded) {
          emit((state as FriendsLoaded).copyWith(
            pendingInvitations: invitations,
          ));
        }
      },
    );
  }

  Future<void> loadPendingInvitationsCount() async {
    debugLog('FriendsCubit: Ładowanie liczby oczekujących zaproszeń');

    final result = await getPendingInvitationsCountUseCase.call(NoParams());

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd ładowania liczby zaproszeń: ${mapFailureToMessage(failure)}');
      },
      (count) {
        debugLog('FriendsCubit: Liczba oczekujących zaproszeń: $count');

        // Jeśli count jest 0, ale spodziewamy się zaproszeń
        if (count == 0) {
          debugLog('FriendsCubit: UWAGA - licznik zaproszeń wynosi 0!');
        }

        if (state is FriendsLoaded) {
          emit((state as FriendsLoaded).copyWith(
            invitationsCount: count,
          ));
        } else if (state is FriendsInitial) {
          debugLog(
              'FriendsCubit: Inicjalizacja stanu z liczbą zaproszeń: $count');
          emit(FriendsLoaded(
            friends: const [],
            pendingInvitations: const [],
            invitationsCount: count,
          ));
        }
      },
    );
  }

  Future<void> respondToInvitation(String invitationId, bool accept) async {
    debugLog(
        'FriendsCubit: Odpowiadanie na zaproszenie: $invitationId, akceptacja: $accept');
    final result = await respondToInvitationUseCase.call(
      RespondToInvitationParams(invitationId, accept),
    );

    result.fold(
      (failure) {
        debugLog(
            'FriendsCubit: Błąd odpowiadania na zaproszenie: ${mapFailureToMessage(failure)}');
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (_) {
        debugLog(
            'FriendsCubit: Pomyślnie przetworzono odpowiedź - odświeżanie danych');
        loadFriends();
        loadPendingInvitationsCount();
      },
    );
  }

  // Pomocnicza metoda do debugowania
  String _getCurrentUserEmail() {
    try {
      final auth = FirebaseAuth.instance;
      return auth.currentUser?.email ?? 'niezalogowany';
    } catch (e) {
      return 'błąd: $e';
    }
  }
}
