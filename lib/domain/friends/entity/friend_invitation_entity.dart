// domain/friends/entity/friend_invitation_entity.dart
import 'package:equatable/equatable.dart';

enum FriendInvitationStatusEntity {
  pending,
  accepted,
  rejected
}

class FriendInvitationEntity extends Equatable {
  final String id;
  final String fromUserEmail;
  final String fromUserName;
  final String toUserEmail;
  final DateTime sentAt;
  final FriendInvitationStatusEntity status;

  const FriendInvitationEntity({
    required this.id,
    required this.fromUserEmail,
    required this.fromUserName,
    required this.toUserEmail,
    required this.sentAt,
    required this.status,
  });

  @override
  List<Object> get props => [id, fromUserEmail, toUserEmail, sentAt, status];
}