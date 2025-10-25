// data/friends/repository/friend_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/friends/mapper/friends_mapper.dart';
import 'package:mealapp/data/friends/source/remote/firebase_friend_service.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FirebaseFriendService firebaseService;

  FriendRepositoryImpl({required this.firebaseService});

  @override
  Future<Either<Failure, List<FriendEntity>>> getFriends() async {
    return handleFirestoreFailure(() async {
      final models = await firebaseService.getFriends();
      return models.map(FriendMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> addFriend(String friendEmail) async {
    return handleFirestoreFailure(() async {
      await firebaseService.addFriend(friendEmail);
    });
  }

  @override
  Future<Either<Failure, void>> removeFriend(String friendEmail) async {
    return handleFirestoreFailure(() async {
      await firebaseService.removeFriend(friendEmail);
    });
  }
}