// presentation/user_info/bloc/friends_state.dart
import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_invitation_entity.dart';

abstract class FriendsState extends Equatable {
  final List<FriendInvitationEntity> pendingInvitations;
  final int invitationsCount;

  const FriendsState({
    this.pendingInvitations = const [],
    this.invitationsCount = 0,
  });

  @override
  List<Object?> get props => [pendingInvitations, invitationsCount];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<FriendEntity> friends;

  const FriendsLoaded({
    required this.friends,
    List<FriendInvitationEntity> pendingInvitations = const [],
    int invitationsCount = 0,
  }) : super(
          pendingInvitations: pendingInvitations,
          invitationsCount: invitationsCount,
        );

  FriendsLoaded copyWith({
    List<FriendEntity>? friends,
    List<FriendInvitationEntity>? pendingInvitations,
    int? invitationsCount,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      invitationsCount: invitationsCount ?? this.invitationsCount,
    );
  }

  @override
  List<Object?> get props => [friends, ...super.props];
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);

  @override
  List<Object?> get props => [message, ...super.props];
}