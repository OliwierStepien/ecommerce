import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/data/freezer_item_share/repository/firebase_freezer_share_repository_impl.dart';

class ShareFreezerWithFriendParams {
  final String friendUid;
  const ShareFreezerWithFriendParams({required this.friendUid});
}

class ShareFreezerWithFriendUseCase {
  final FirebaseFreezerShareRepositoryImpl repo;
  ShareFreezerWithFriendUseCase(this.repo);

  Future<Either<Failure, void>> call(ShareFreezerWithFriendParams p) {
    return repo.shareFreezerWithFriend(friendUid: p.friendUid);
  }
}