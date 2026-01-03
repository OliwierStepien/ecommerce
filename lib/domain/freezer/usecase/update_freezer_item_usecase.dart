import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class UpdateFreezerItemUseCase
    implements UseCase<Either<Failure, void>, FreezerItemEntity> {
  final FreezerItemRepository repository;

  UpdateFreezerItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(FreezerItemEntity params) {
    return repository.update(params);
  }
}