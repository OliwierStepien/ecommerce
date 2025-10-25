// domain/friends/entity/friend_entity.dart
import 'package:equatable/equatable.dart';

class FriendEntity extends Equatable {
  final String friendEmail;
  final String friendName;
  final DateTime addedAt;

  const FriendEntity({
    required this.friendEmail,
    required this.friendName,
    required this.addedAt,
  });

  @override
  List<Object> get props => [friendEmail, friendName, addedAt];
}