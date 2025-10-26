// domain/friends/usecase/respond_to_invitation_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class RespondToInvitationParams {
  final String invitationId;
  final bool accept;

  RespondToInvitationParams(this.invitationId, this.accept);
}

class RespondToInvitationUseCase
    implements UseCase<Either<Failure, void>, RespondToInvitationParams> {
  final FriendRepository repository;

  RespondToInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RespondToInvitationParams params) async {
    return await repository.respondToInvitation(params.invitationId, params.accept);
  }
}