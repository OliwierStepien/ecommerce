import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/shopping_list_clear/repository/shopping_list_clear_repository.dart';

class ClearShoppingListUseCase {
  final ShoppingListClearRepository repo;
  ClearShoppingListUseCase(this.repo);

  Future<Either<Failure, void>> call() => repo.clearAll();
}