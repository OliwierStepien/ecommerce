import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';
import 'package:mealapp/domain/grocery/repository/grocery_repository.dart';

class GetGroceriesUseCase
    implements UseCase<Either<Failure, List<GroceryEntity>>, NoParams> {
  final GroceryRepository repository;

  GetGroceriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<GroceryEntity>>> call(NoParams params) {
    return repository.getGroceries();
  }
}