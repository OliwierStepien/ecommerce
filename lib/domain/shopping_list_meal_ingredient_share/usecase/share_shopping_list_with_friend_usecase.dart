// domain/shopping_list_share/usecase/share_shopping_list_with_friend_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient_share/repository/firebase_shopping_list_share_repository_impl.dart';

class ShareShoppingListWithFriendParams {
  final String friendUid;

  const ShareShoppingListWithFriendParams({required this.friendUid});
}

class ShareShoppingListWithFriendUseCase {
  final FirebaseShoppingListShareRepositoryImpl repo;

  ShareShoppingListWithFriendUseCase(this.repo);

  Future<Either<Failure, void>> call(ShareShoppingListWithFriendParams p) {
    return repo.shareShoppingListWithFriend(friendUid: p.friendUid);
  }
}