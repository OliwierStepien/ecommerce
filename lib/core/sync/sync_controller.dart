import 'package:flutter/foundation.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/sync/shopping_list_custom_item_sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/sync/shopping_list_meal_ingredient_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';

class SyncController {
  final ShoppingListMealIngredientSyncService _shoppingListSyncService;
  final ShoppingListCustomItemSyncService _customItemsSyncService;
  final HiveShoppingListMealIngredientService _hiveService;
  final HiveShoppingListCustomItemService _customItemsHiveService;

  bool _inProgress = false;
  DateTime? _lastSyncTime;
  static const int _logThresholdMs = 100; // loguj tylko gdy >100ms lub przerwa

  SyncController({
    required ShoppingListMealIngredientSyncService shoppingListSyncService,
    required ShoppingListCustomItemSyncService customItemsSyncService,
    required HiveShoppingListMealIngredientService hiveService,
    required HiveShoppingListCustomItemService customItemsHiveService,
  })  : _shoppingListSyncService = shoppingListSyncService,
        _customItemsSyncService = customItemsSyncService,
        _hiveService = hiveService,
        _customItemsHiveService = customItemsHiveService;

  /// Właściwa synchronizacja (nie wywołuje strategii wewnętrznie).
  Future<void> syncData() async {
    if (_inProgress) {
      debugPrint(
          '[SyncController] syncData: already in progress, skipping duplicate call');
      return;
    }
    _inProgress = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      final execStopwatch = Stopwatch()..start();
      await _executeSyncOperations();
      execStopwatch.stop();

      final clearStopwatch = Stopwatch()..start();
      await _hiveService.clearSyncedDeletedItems();
      await _customItemsHiveService.clearSyncedDeletedItems();
      clearStopwatch.stop();
    } catch (e) {
      debugPrint('[SyncController] syncData: error during sync: $e');
      rethrow;
    } finally {
      totalStopwatch.stop();
      final total = totalStopwatch.elapsedMilliseconds;
      final now = DateTime.now();
      final shouldLog = total > _logThresholdMs ||
          (_lastSyncTime == null) ||
          now.difference(_lastSyncTime!) > const Duration(seconds: 1);
      if (shouldLog) {
        debugPrint('[SyncController] syncData: total time = ${total}ms');
      }
      _lastSyncTime = now;
      _inProgress = false;
    }
  }

  Future<void> _executeSyncOperations() async {
    try {
      final waitStopwatch = Stopwatch()..start();
      await Future.wait([
        _shoppingListSyncService.syncData(),
        _customItemsSyncService.syncData(),
      ]);
      waitStopwatch.stop();
      if (waitStopwatch.elapsedMilliseconds > _logThresholdMs) {
        debugPrint(
            '[SyncController] _executeSyncOperations: both services finished in ${waitStopwatch.elapsedMilliseconds}ms');
      }
    } catch (e) {
      debugPrint(
          '[SyncController] _executeSyncOperations: sync failed. Error: $e');
      // retry powinien być zaplanowany przez zewnętrzną strategię (np. DebounceSyncStrategy)
      rethrow;
    }
  }
}