import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/freezer/mapper/freezer_item_mapper.dart';
import 'package:mealapp/data/freezer/source/remote/firebase_freezer_item_service.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class FirebaseFreezerItemRepositoryImpl implements FreezerItemRepository {
  final FirebaseFreezerItemService _service;

  FirebaseFreezerItemRepositoryImpl({required FirebaseFreezerItemService service})
      : _service = service;

  @override
  Future<Either<Failure, void>> add(FreezerItemEntity item) {
    return handleFirestoreFailure(() async {
      await _service.add(FreezerItemMapper.toModel(item));
    });
  }

  @override
  Future<Either<Failure, List<FreezerItemEntity>>> getAll() {
    return handleFirestoreFailure(() async {
      final models = await _service.getAll();
      return models.map(FreezerItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> remove(String itemId) {
    return handleFirestoreFailure(() async {
      await _service.remove(itemId);
    });
  }

  @override
  Future<Either<Failure, void>> restore(FreezerItemEntity item) {
    // restore = upsert
    return handleFirestoreFailure(() async {
      await _service.add(FreezerItemMapper.toModel(item));
    });
  }

  @override
  Future<Either<Failure, void>> update(FreezerItemEntity item) {
    return handleFirestoreFailure(() async {
      await _service.update(FreezerItemMapper.toModel(item));
    });
  }

  // w remote repo nie potrzebujesz realnie tych metod (sync robi local)
  @override
  Future<Either<Failure, List<FreezerItemEntity>>> getUnsyncedChanges() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> markAsSynced(String itemId) async {
    return const Right(null);
  }
}