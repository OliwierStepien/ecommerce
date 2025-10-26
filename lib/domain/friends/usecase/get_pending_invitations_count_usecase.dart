// domain/friends/usecase/get_pending_invitations_count_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';

class GetPendingInvitationsCountUseCase
    implements UseCase<Either<Failure, int>, NoParams> {
  final FriendRepository repository;

  GetPendingInvitationsCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getPendingInvitationsCount();
  }
}