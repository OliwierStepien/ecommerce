import 'package:hive/hive.dart';
import 'package:mealapp/data/shopping_list/model/shopping_list_item_model.dart';

abstract class HiveShoppingListService {
  Future<List<ShoppingListItemModel>> getItems();
  Future<void> saveItems(List<ShoppingListItemModel> items);
  Future<void> addItem(ShoppingListItemModel item);
  Future<void> removeItem(String ingredientId);
}

class ShoppingListHiveServiceImpl implements HiveShoppingListService {
  @override
  Future<List<ShoppingListItemModel>> getItems() async {
    final box = Hive.box<ShoppingListItemModel>('shoppingListItems');
    return box.values.toList();
  }

  @override
  Future<void> saveItems(List<ShoppingListItemModel> items) async {
    final box = Hive.box<ShoppingListItemModel>('shoppingListItems');
    await box.clear();
    await box.addAll(items);
  }

  @override
  Future<void> addItem(ShoppingListItemModel item) async {
    final box = Hive.box<ShoppingListItemModel>('shoppingListItems');
    await box.put(item.ingredientId, item);
  }

  @override
  Future<void> removeItem(String ingredientId) async {
    final box = Hive.box<ShoppingListItemModel>('shoppingListItems');
    await box.delete(ingredientId);
  }
}