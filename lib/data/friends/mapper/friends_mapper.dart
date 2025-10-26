// data/friends/mapper/friends_mapper.dart
import 'package:mealapp/data/friends/model/friends_invitation_model.dart';
import 'package:mealapp/data/friends/model/friends_model.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/entity/friend_invitation_entity.dart';

class FriendMapper {
  static FriendEntity toEntity(FriendModel model) {
    return FriendEntity(
      friendEmail: model.friendEmail,
      friendName: model.friendName,
      addedAt: model.addedAt,
    );
  }

  static FriendModel toModel(FriendEntity entity) {
    return FriendModel(
      friendEmail: entity.friendEmail,
      friendName: entity.friendName,
      addedAt: entity.addedAt,
    );
  }

  static FriendInvitationEntity invitationToEntity(FriendInvitationModel model) {
    return FriendInvitationEntity(
      id: model.id,
      fromUserEmail: model.fromUserEmail,
      fromUserName: model.fromUserName,
      toUserEmail: model.toUserEmail,
      sentAt: model.sentAt,
      status: _mapInvitationStatus(model.status),
    );
  }

  static FriendInvitationStatusEntity _mapInvitationStatus(
      FriendInvitationStatus status) {
    switch (status) {
      case FriendInvitationStatus.pending:
        return FriendInvitationStatusEntity.pending;
      case FriendInvitationStatus.accepted:
        return FriendInvitationStatusEntity.accepted;
      case FriendInvitationStatus.rejected:
        return FriendInvitationStatusEntity.rejected;
    }
  }
}