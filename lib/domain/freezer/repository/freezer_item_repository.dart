import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';

abstract class FreezerItemRepository {
  Future<Either<Failure, void>> add(FreezerItemEntity item);
  Future<Either<Failure, void>> remove(String itemId);
  Future<Either<Failure, void>> restore(FreezerItemEntity item);
  Future<Either<Failure, void>> update(FreezerItemEntity item);

  Future<Either<Failure, List<FreezerItemEntity>>> getAll();
  Future<Either<Failure, List<FreezerItemEntity>>> getUnsyncedChanges();
  Future<Either<Failure, void>> markAsSynced(String itemId);
}