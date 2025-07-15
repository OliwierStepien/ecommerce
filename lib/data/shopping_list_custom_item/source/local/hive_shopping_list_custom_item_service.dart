import 'package:hive/hive.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

abstract class HiveShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(String customItemId, {bool isOnline});
  Future<List<ShoppingListCustomItemModel>> getCustomItemToShoppingList();
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem();
  Future<void> markShoppingListCustomItemAsSynced(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getUnsyncedChangesForShoppingListCustomItem();
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> clearSyncedDeletedItems();
}

class HiveShoppingListCustomItemServiceImpl implements HiveShoppingListCustomItemService {
  Box<ShoppingListCustomItemModel> get _box =>
      Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

  @override
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    await _box.put(
      item.customItemId,
      item.copyWith(isDeleted: false),
    );

    final items = await getCustomItemToShoppingList();
    print('✅ Dodano własny składnik: ${item.customItemName}');
    print('🛒 Liczba własnych składników: ${items.length}');
  }

  @override
  Future<void> removeCustomItemFromShoppingList(String customItemId, {bool isOnline = false}) async {
    final model = _box.get(customItemId);

    if (model != null) {
      if (isOnline) {
        await _box.delete(customItemId);
        print('🗑️ Trwale usunięto zsynchronizowany składnik: $customItemId');
      } else {
        await _box.put(
          customItemId,
          model.copyWith(isDeleted: true, isSynced: false),
        );
        print('❌ Oznaczono jako usunięty: ${model.customItemName}');
      }
    }
  }

  @override
  Future<List<ShoppingListCustomItemModel>> getCustomItemToShoppingList() async {
    return _box.values.where((item) => !item.isDeleted).toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem() async {
    return _box.values.where((item) => !item.isSynced && !item.isDeleted).toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>> getUnsyncedChangesForShoppingListCustomItem() async {
    return _box.values.where((item) => !item.isSynced).toList();
  }

  @override
  Future<void> markShoppingListCustomItemAsSynced(String customItemId) async {
    final model = _box.get(customItemId);

    if (model != null) {
      await _box.put(
        customItemId,
        model.copyWith(isSynced: true),
      );
      print('✅ Zaznaczono jako zsynchronizowany: ${model.customItemName}');
    }
  }

  @override
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    final model = _box.get(item.customItemId);

    final toSave = model != null
        ? model.copyWith(isDeleted: false)
        : item.copyWith(isDeleted: false, isSynced: false);

    await _box.put(item.customItemId, toSave);

    final allItems = _box.values.toList();
    final activeItems = allItems.where((i) => !i.isDeleted).toList();
    final deletedItems = allItems.where((i) => i.isDeleted).toList();

    print('♻️ Przywrócono składnik: ${item.customItemName}');
    print('📦 Ilość wpisów w Hive: ${allItems.length}');
    print('🛒 Aktywne: ${activeItems.length}, 🗑️ Usunięte: ${deletedItems.length}');
  }

  @override
  Future<void> clearSyncedDeletedItems() async {
    final keysToDelete = _box.keys.where((key) {
      final item = _box.get(key);
      return item != null && item.isDeleted && item.isSynced;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
      print('🧹 Usunięto trwale zsynchronizowany składnik: $key');
    }
  }
}