import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/sync/shopping_list_custom_item_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/sync/shopping_list_meal_ingredient_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';

/// Kontroler synchronizacji — scala strategię synchronizacji z
/// konkretnymi serwisami danych oraz ich lokalnym cache.
/// Umożliwia wykonanie pełnej operacji synchronizacji „na żądanie”.
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

  /// Główna metoda synchronizacji:
  /// 1. wyzwala strategię (np. debounce),
  /// 2. synchronizuje dane z serwisami,
  /// 3. usuwa zsynchronizowane rekordy lokalne (np. usunięte elementy).
  Future<void> syncData() async {
    await _syncStrategy.onDataChanged();
    await _executeSyncOperations();
    await _hiveService.clearSyncedDeletedItems();
  }

  /// Uruchamia faktyczną synchronizację danych (równolegle)
  Future<void> _executeSyncOperations() async {
    try {
      await Future.wait([
        _shoppingListSyncService.syncData(),
        _customItemsSyncService.syncData(),
      ]);
    } catch (e) {
      // W razie błędu ponawiamy próbę synchronizacji
      _syncStrategy.onDataChanged();
      rethrow;
    }
  }
}