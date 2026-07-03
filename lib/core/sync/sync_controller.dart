import 'package:flutter/foundation.dart';
import 'package:mealapp/data/favorite_meal/repository/sync/favorite_meal_sync_service.dart';
import 'package:mealapp/data/freezer/repository/sync/freezer_item_sync_service.dart';
import 'package:mealapp/data/freezer/source/local/hive_freezer_item_service.dart';
import 'package:mealapp/data/planned_meal/repository/sync/planned_meal_sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/sync/shopping_list_custom_item_sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/sync/shopping_list_meal_ingredient_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';

class SyncController {
  final PlannedMealSyncService _plannedMealSyncService;
  final FavoriteMealSyncService _favoriteMealSyncService;

  final ShoppingListMealIngredientSyncService _shoppingListSyncService;
  final ShoppingListCustomItemSyncService _customItemsSyncService;

  // ✅ FREEZER
  final FreezerItemSyncService _freezerItemSyncService;

  // lokalne czyszczenie zsynchronizowanych "deleted"
  final HiveShoppingListMealIngredientService _hiveService;
  final HiveShoppingListCustomItemService _customItemsHiveService;

  // ✅ FREEZER: local clear
  final HiveFreezerItemService _freezerHiveService;

  bool _inProgress = false;
  DateTime? _lastSyncTime;
  static const int _logThresholdMs = 100;

  SyncController({
    required PlannedMealSyncService plannedMealSyncService,
    required FavoriteMealSyncService favoriteMealSyncService,
    required ShoppingListMealIngredientSyncService shoppingListSyncService,
    required ShoppingListCustomItemSyncService customItemsSyncService,

    // ✅ FREEZER
    required FreezerItemSyncService freezerItemSyncService,

    required HiveShoppingListMealIngredientService hiveService,
    required HiveShoppingListCustomItemService customItemsHiveService,

    // ✅ FREEZER
    required HiveFreezerItemService freezerHiveService,
  })  : _plannedMealSyncService = plannedMealSyncService,
        _favoriteMealSyncService = favoriteMealSyncService,
        _shoppingListSyncService = shoppingListSyncService,
        _customItemsSyncService = customItemsSyncService,
        _freezerItemSyncService = freezerItemSyncService,
        _hiveService = hiveService,
        _customItemsHiveService = customItemsHiveService,
        _freezerHiveService = freezerHiveService;

  Future<void> syncData() async {
    if (_inProgress) {
      debugPrint(
        '[SyncController] syncData: already in progress, skipping duplicate call',
      );
      return;
    }

    _inProgress = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      final execStopwatch = Stopwatch()..start();
      await _executeSyncOperations();
      execStopwatch.stop();

      // Po zakończeniu synca: posprzątaj zsynchronizowane "deleted"
      final clearStopwatch = Stopwatch()..start();
      await _hiveService.clearSyncedDeletedItems();
      await _customItemsHiveService.clearSyncedDeletedItems();

      // ✅ FREEZER
      await _freezerHiveService.clearSyncedDeleted();

      clearStopwatch.stop();

      if (clearStopwatch.elapsedMilliseconds > _logThresholdMs) {
        debugPrint(
          '[SyncController] clearSyncedDeletedItems took ${clearStopwatch.elapsedMilliseconds}ms',
        );
      }
    } catch (e, st) {
      debugPrint('[SyncController] syncData: error during sync: $e\n$st');
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
        _wrap('PlannedMealSync', () => _plannedMealSyncService.syncData()),
        _wrap('FavoriteMealSync', () => _favoriteMealSyncService.syncData()),
        _wrap('ShoppingListMealIngSync', () => _shoppingListSyncService.syncData()),
        _wrap('ShoppingListCustomItemSync', () => _customItemsSyncService.syncData()),

        // ✅ FREEZER
        _wrap('FreezerItemSync', () => _freezerItemSyncService.syncData()),
      ]);

      waitStopwatch.stop();
      if (waitStopwatch.elapsedMilliseconds > _logThresholdMs) {
        debugPrint(
          '[SyncController] _executeSyncOperations finished in ${waitStopwatch.elapsedMilliseconds}ms',
        );
      }
    } catch (e, st) {
      debugPrint('[SyncController] _executeSyncOperations: sync failed. Error: $e\n$st');
      rethrow;
    }
  }

  Future<void> _wrap(String label, Future<void> Function() run) async {
    final sw = Stopwatch()..start();
    try {
      await run();
      sw.stop();
      debugPrint('[SyncController][$label] ✅ ok in ${sw.elapsedMilliseconds}ms');
    } catch (e, st) {
      sw.stop();
      debugPrint('[SyncController][$label] ❌ error in ${sw.elapsedMilliseconds}ms: $e\n$st');
      rethrow;
    }
  }
}