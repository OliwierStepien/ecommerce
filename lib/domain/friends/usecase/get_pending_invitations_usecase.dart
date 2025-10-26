// domain/friends/usecase/get_pending_invitations_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/entity/friend_invitation_entity.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class GetPendingInvitationsUseCase
    implements UseCase<Either<Failure, List<FriendInvitationEntity>>, NoParams> {
  final FriendRepository repository;

  GetPendingInvitationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FriendInvitationEntity>>> call(NoParams params) async {
    return await repository.getPendingInvitations();
  }
}