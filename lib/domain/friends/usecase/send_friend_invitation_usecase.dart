// domain/friends/usecase/send_friend_invitation_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class SendFriendInvitationUseCase
    implements UseCase<Either<Failure, void>, String> {
  final FriendRepository repository;

  SendFriendInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String friendEmail) async {
    return await repository.sendFriendInvitation(friendEmail);
  }
}