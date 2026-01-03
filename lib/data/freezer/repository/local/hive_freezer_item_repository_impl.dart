import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/freezer/mapper/freezer_item_mapper.dart';
import 'package:mealapp/data/freezer/source/local/hive_freezer_item_service.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class HiveFreezerItemRepositoryImpl implements FreezerItemRepository {
  final HiveFreezerItemService _service;

  HiveFreezerItemRepositoryImpl({required HiveFreezerItemService service})
      : _service = service;

  @override
  Future<Either<Failure, void>> add(FreezerItemEntity item) {
    return handleHiveFailure(() async {
      await _service.add(FreezerItemMapper.toModel(item));
    });
  }

  @override
  Future<Either<Failure, List<FreezerItemEntity>>> getAll() {
    return handleHiveFailure(() async {
      final models = await _service.getAll();
      return models.map(FreezerItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> remove(String itemId) {
    return handleHiveFailure(() async {
      await _service.remove(itemId);
    });
  }

  @override
  Future<Either<Failure, void>> restore(FreezerItemEntity item) {
    return handleHiveFailure(() async {
      await _service.restore(FreezerItemMapper.toModel(item));
    });
  }

  @override
  Future<Either<Failure, void>> update(FreezerItemEntity item) {
    return handleHiveFailure(() async {
      await _service.update(FreezerItemMapper.toModel(item));
    });
  }

  @override
  Future<Either<Failure, List<FreezerItemEntity>>> getUnsyncedChanges() {
    return handleHiveFailure(() async {
      final models = await _service.getUnsyncedChanges();
      return models.map(FreezerItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markAsSynced(String itemId) {
    return handleHiveFailure(() async {
      await _service.markAsSynced(itemId);
    });
  }
}