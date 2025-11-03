import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/data/planned_meal_share/repository/remote/firebase_meal_share_repository_impl.dart';

class SharePlannedMealsWithFriendParams {
  final String friendUid;
  final DateTime start;
  final DateTime end;

  const SharePlannedMealsWithFriendParams({
    required this.friendUid,
    required this.start,
    required this.end,
  });
}

class SharePlannedMealsWithFriendUseCase {
  final FirebaseMealShareRepositoryImpl repo;

  SharePlannedMealsWithFriendUseCase(this.repo);

  Future<Either<Failure, void>> call(SharePlannedMealsWithFriendParams p) {
    return repo.sharePlannedMealsWithFriend(
      friendUid: p.friendUid,
      start: p.start,
      end: p.end,
    );
  }
}