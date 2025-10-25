// domain/friends/repository/friend_repository.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';

abstract class FriendRepository {
  Future<Either<Failure, List<FriendEntity>>> getFriends();
  Future<Either<Failure, void>> addFriend(String friendEmail);
  Future<Either<Failure, void>> removeFriend(String friendEmail);
}