import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/freezer/model/freezer_item_model.dart';
import 'package:mealapp/data/freezer/source/local/hive_freezer_item_service.dart';
import 'package:mealapp/data/freezer_item_share/source/remote/firebase_freezer_share_service.dart';

class FirebaseFreezerShareRepositoryImpl {
  final FirebaseFreezerShareService _service;
  final HiveFreezerItemService _hive;

  FirebaseFreezerShareRepositoryImpl(this._service, this._hive);

  Future<Either<Failure, void>> shareFreezerWithFriend({
    required String friendUid,
  }) {
    return handleFirestoreFailure(() async {
      final all = await _hive.getAll();
      final toShare = all.where((e) => !e.isDeleted).toList();

      await _service.shareFreezerWithFriend(
        friendUid: friendUid,
        itemsToShare: toShare,
      );
      return;
    });
  }

  Future<Either<Failure, void>> shareSelectedFreezerItemsWithFriend({
    required String friendUid,
    required List<FreezerItemModel> selected,
  }) {
    return handleFirestoreFailure(() async {
      final toShare = selected.where((e) => !e.isDeleted).toList();

      await _service.shareFreezerWithFriend(
        friendUid: friendUid,
        itemsToShare: toShare,
      );
      return;
    });
  }
}