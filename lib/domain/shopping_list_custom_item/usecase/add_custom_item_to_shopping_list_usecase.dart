import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

class AddCustomItemToShoppingListUseCase
    implements UseCase<Either<Failure, void>, ShoppingListCustomItemEntity> {
  final ShoppingListCustomItemRepository repository;

  AddCustomItemToShoppingListUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      {ShoppingListCustomItemEntity? params}) async {
    if (params == null) {
      return Left(GeneralFailure());
    }
    return await repository.addCustomItemToShoppingList(params);
  }
}