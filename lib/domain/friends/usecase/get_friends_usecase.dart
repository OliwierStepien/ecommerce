// domain/friends/usecase/get_friends_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/entity/friend_entity.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class GetFriendsUseCase
    implements UseCase<Either<Failure, List<FriendEntity>>, NoParams> {
  final FriendRepository repository;

  GetFriendsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FriendEntity>>> call(NoParams params) async {
    return await repository.getFriends();
  }
}