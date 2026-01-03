import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class GetFreezerItemsUseCase
    implements UseCase<Either<Failure, List<FreezerItemEntity>>, NoParams> {
  final FreezerItemRepository repository;

  GetFreezerItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FreezerItemEntity>>> call(NoParams params) async {
    return repository.getAll();
  }
}