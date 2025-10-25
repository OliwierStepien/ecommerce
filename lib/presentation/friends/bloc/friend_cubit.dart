// presentation/user_info/bloc/friends_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/usecase/add_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/remove_friends_usecase.dart';
import 'package:mealapp/presentation/friends/bloc/friend_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final GetFriendsUseCase getFriendsUseCase;
  final AddFriendUseCase addFriendUseCase;
  final RemoveFriendUseCase removeFriendUseCase;

  FriendsCubit({
    required this.getFriendsUseCase,
    required this.addFriendUseCase,
    required this.removeFriendUseCase,
  }) : super(FriendsInitial());

  Future<void> loadFriends() async {
    emit(FriendsLoading());
    
    final result = await getFriendsUseCase.call(NoParams());
    
    result.fold(
      (failure) {
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (friends) {
        emit(FriendsLoaded(friends));
      },
    );
  }

  Future<void> addFriend(String email) async {
    final result = await addFriendUseCase.call(email);
    
    result.fold(
      (failure) {
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (_) {
        loadFriends(); // Odśwież listę
      },
    );
  }

  Future<void> removeFriend(String friendEmail) async {
    final result = await removeFriendUseCase.call(friendEmail);
    
    result.fold(
      (failure) {
        emit(FriendsError(mapFailureToMessage(failure)));
      },
      (_) {
        loadFriends(); // Odśwież listę
      },
    );
  }
}