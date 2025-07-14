import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/sync/shopping_list_custom_item_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/sync/shopping_list_meal_ingredient_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';

class SyncController {
  final SyncStrategy _syncStrategy;
  final ShoppingListMealIngredientSyncService _shoppingListSyncService;
  final ShoppingListCustomItemSyncService _customItemsSyncService;
  final HiveShoppingListMealIngredientService _hiveService;

  SyncController({
    required SyncStrategy syncStrategy,
    required ShoppingListMealIngredientSyncService shoppingListSyncService,
    required ShoppingListCustomItemSyncService customItemsSyncService,
    required HiveShoppingListMealIngredientService hiveService,
  })  : _syncStrategy = syncStrategy,
        _shoppingListSyncService = shoppingListSyncService,
        _customItemsSyncService = customItemsSyncService,
        _hiveService = hiveService;

  Future<void> syncData() async {
    await _syncStrategy.onDataChanged();
    await _executeSyncOperations();
    await _hiveService.clearSyncedDeletedItems(); // Dodane czyszczenie
  }

  Future<void> _executeSyncOperations() async {
    try {
      await Future.wait([
        _shoppingListSyncService.syncData(),
        _customItemsSyncService.syncData(),
      ]);
    } catch (e) {
      _syncStrategy.onDataChanged();
      rethrow;
    }
  }
}