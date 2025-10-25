// data/friends/mapper/friend_mapper.dart
import 'package:mealapp/data/friends/model/friends_model.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';

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
}