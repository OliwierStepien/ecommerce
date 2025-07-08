import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

class GetShoppingListCustomItemUseCase
    implements UseCase<Either<Failure, List<ShoppingListCustomItemEntity>>, void> {
  final ShoppingListCustomItemRepository repository;

  GetShoppingListCustomItemUseCase(this.repository);

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>> call(
      {void params}) async {
    return await repository.getCustomItemToShoppingList();
  }
}