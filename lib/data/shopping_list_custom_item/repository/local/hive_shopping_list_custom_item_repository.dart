import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

class HiveShoppingListCustomItemRepositoryImpl
    implements ShoppingListCustomItemRepository {
  final HiveShoppingListCustomItemService _hiveShoppingListCustomItemService;

  HiveShoppingListCustomItemRepositoryImpl({
    required HiveShoppingListCustomItemService
        hiveShoppingListCustomItemService,
  }) : _hiveShoppingListCustomItemService = hiveShoppingListCustomItemService;

  @override
  Future<Either<Failure, void>> addCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity) async {
    return handleHiveFailure(() async {
      await _hiveShoppingListCustomItemService.addCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(shoppingListCustomItemEntity),
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId) async {
    return handleHiveFailure(() async {
      await _hiveShoppingListCustomItemService
          .removeCustomItemFromShoppingList(customItemId);
    });
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getCustomItemToShoppingList() async {
    return handleHiveFailure(() async {
      final models = await _hiveShoppingListCustomItemService
          .getCustomItemFromShoppingList();
      return models.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedShoppingListCustomItem() async {
    return handleHiveFailure(() async {
      final models = await _hiveShoppingListCustomItemService
          .getUnsyncedShoppingListCustomItem();
      return models.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedChangesForShoppingListCustomItem() async {
    return handleHiveFailure(() async {
      final models = await _hiveShoppingListCustomItemService
          .getUnsyncedChangesForShoppingListCustomItem();
      return models.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
      String customItemId) async {
    return handleHiveFailure(() async {
      await _hiveShoppingListCustomItemService
          .markShoppingListCustomItemAsSynced(customItemId);
    });
  }

  @override
  Future<Either<Failure, void>> restoreCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity) async {
    return handleHiveFailure(() async {
      await _hiveShoppingListCustomItemService.restoreCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(shoppingListCustomItemEntity),
      );
    });
  }

  @override
  Future<Either<Failure, void>> updateCustomItemToShoppingList(
    ShoppingListCustomItemEntity entity,
  ) async {
    return handleHiveFailure(() async {
      await _hiveShoppingListCustomItemService.updateCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(entity),
      );
    });
  }
}
