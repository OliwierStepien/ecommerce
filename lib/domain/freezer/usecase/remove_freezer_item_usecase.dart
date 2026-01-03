import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class RemoveFreezerItemUseCase
    implements UseCase<Either<Failure, void>, String> {
  final FreezerItemRepository repository;

  RemoveFreezerItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return repository.remove(params);
  }
}