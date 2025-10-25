// presentation/user_info/bloc/friends_state.dart
import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';

abstract class FriendsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<FriendEntity> friends;

  FriendsLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}

class FriendsError extends FriendsState {
  final String message;

  FriendsError(this.message);

  @override
  List<Object?> get props => [message];
}