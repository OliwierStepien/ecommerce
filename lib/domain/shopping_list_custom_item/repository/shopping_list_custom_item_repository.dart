import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';

abstract class ShoppingListCustomItemRepository {
  Future<Either<Failure, void>> addCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity);
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId);
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>> getCustomItemToShoppingList();
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>> getUnsyncedShoppingListCustomItem();
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
      String customItemId);
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedChangesForShoppingListCustomItem();
}
