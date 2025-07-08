import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

class RemoveCustomItemFromShoppingListUseCase
    implements UseCase<Either<Failure, void>, String> {
  final ShoppingListCustomItemRepository repository;

  RemoveCustomItemFromShoppingListUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({String? params}) async {
    if (params == null) {
      return Left(GeneralFailure());
    }
    return await repository.removeCustomItemFromShoppingList(params);
  }
}