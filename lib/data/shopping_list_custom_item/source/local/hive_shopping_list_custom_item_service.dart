import 'package:hive/hive.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

abstract class HiveShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel shoppingListCustomItemModel);
  Future<void> removeCustomItemFromShoppingList(String customItemId,
      {bool isOnline});
  Future<List<ShoppingListCustomItemModel>> getCustomItemToShoppingList();
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem();
  Future<void> markShoppingListCustomItemAsSynced(String customItemId);
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedChangesForShoppingListCustomItem();
}

class HiveShoppingListCustomItemServiceImpl
    implements HiveShoppingListCustomItemService {
  Box<ShoppingListCustomItemModel> get _box =>
      Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

  @override
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel shoppingListCustomItemModel) async {
    await _box.put(
        shoppingListCustomItemModel.customItemId, shoppingListCustomItemModel);
  }

  @override
  Future<void> removeCustomItemFromShoppingList(String customItemId,
      {bool isOnline = false}) async {
    final key = customItemId;
    if (isOnline) {
      await _box.delete(key);
    } else {
      final model = _box.get(key);
      if (model != null) {
        await _box.put(
            key,
            ShoppingListCustomItemModel(
              customItemId: model.customItemId,
              customItemName: model.customItemName,
              customItemCategory: model.customItemCategory,
              isSynced: false,
              isDeleted: true,
            ));
      }
    }
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getCustomItemToShoppingList() async {
    return _box.values.where((model) => !model.isDeleted).toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedChangesForShoppingListCustomItem() async {
    return _box.values
        .where((model) => !model.isSynced && !model.isDeleted)
        .toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedShoppingListCustomItem() async {
    return _box.values.where((model) => !model.isSynced).toList();
  }

  @override
  Future<void> markShoppingListCustomItemAsSynced(String customItemId) async {
    final key = customItemId;
    final model = _box.get(key);
    if (model != null && !model.isDeleted) {
      await _box.put(
          key,
          ShoppingListCustomItemModel(
            customItemId: model.customItemId,
            customItemName: model.customItemName,
            customItemCategory: model.customItemCategory,
            isSynced: true,
            isDeleted: model.isDeleted,
          ));
    }
  }
}
