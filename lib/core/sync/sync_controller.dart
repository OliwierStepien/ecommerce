import 'package:flutter/foundation.dart';
import 'package:mealapp/data/planned_meal/repository/sync/planned_meal_sync_service.dart';
import 'package:mealapp/data/favorite_meal/repository/sync/favorite_meal_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/sync/shopping_list_meal_ingredient_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/sync/shopping_list_custom_item_sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';

class SyncController {
  // ✅ DOŁĄCZONE: planowane i ulubione
  final PlannedMealSyncService _plannedMealSyncService;
  final FavoriteMealSyncService _favoriteMealSyncService;

  // ✅ Już były: zakupy
  final ShoppingListMealIngredientSyncService _shoppingListSyncService;
  final ShoppingListCustomItemSyncService _customItemsSyncService;

  // lokalne czyszczenie zsynchronizowanych "deleted"
  final HiveShoppingListMealIngredientService _hiveService;
  final HiveShoppingListCustomItemService _customItemsHiveService;

  bool _inProgress = false;
  DateTime? _lastSyncTime;
  static const int _logThresholdMs = 100; // loguj tylko gdy >100ms lub przerwa

  SyncController({
    // nowo dodane
    required PlannedMealSyncService plannedMealSyncService,
    required FavoriteMealSyncService favoriteMealSyncService,

    // były
    required ShoppingListMealIngredientSyncService shoppingListSyncService,
    required ShoppingListCustomItemSyncService customItemsSyncService,
    required HiveShoppingListMealIngredientService hiveService,
    required HiveShoppingListCustomItemService customItemsHiveService,
  })  : _plannedMealSyncService = plannedMealSyncService,
        _favoriteMealSyncService = favoriteMealSyncService,
        _shoppingListSyncService = shoppingListSyncService,
        _customItemsSyncService = customItemsSyncService,
        _hiveService = hiveService,
        _customItemsHiveService = customItemsHiveService;

  /// Właściwa synchronizacja (nie wywołuje strategii wewnętrznie).
  Future<void> syncData() async {
    if (_inProgress) {
      debugPrint('[SyncController] syncData: already in progress, skipping duplicate call');
      return;
    }
    _inProgress = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      final execStopwatch = Stopwatch()..start();
      await _executeSyncOperations();
      execStopwatch.stop();

      // Po zakończeniu synca: posprzątaj zsynchronizowane "deleted" w zakupach
      final clearStopwatch = Stopwatch()..start();
      await _hiveService.clearSyncedDeletedItems();
      await _customItemsHiveService.clearSyncedDeletedItems();
      clearStopwatch.stop();

      if (clearStopwatch.elapsedMilliseconds > _logThresholdMs) {
        debugPrint('[SyncController] clearSyncedDeletedItems took ${clearStopwatch.elapsedMilliseconds}ms');
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

      // ✅ Uruchamiamy WSZYSTKIE serwisy równolegle
      await Future.wait([
        // Planned & Favorite
        _wrap('PlannedMealSync', () => _plannedMealSyncService.syncData()),
        _wrap('FavoriteMealSync', () => _favoriteMealSyncService.syncData()),

        // Shopping Lists
        _wrap('ShoppingListMealIngSync', () => _shoppingListSyncService.syncData()),
        _wrap('ShoppingListCustomItemSync', () => _customItemsSyncService.syncData()),
      ]);

      waitStopwatch.stop();
      if (waitStopwatch.elapsedMilliseconds > _logThresholdMs) {
        debugPrint('[SyncController] _executeSyncOperations finished in ${waitStopwatch.elapsedMilliseconds}ms');
      }
    } catch (e, st) {
      debugPrint('[SyncController] _executeSyncOperations: sync failed. Error: $e\n$st');
      // retry powinien być zaplanowany przez zewnętrzną strategię (np. DebounceSyncStrategy)
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

/// Interfejs dla serwisów, które obsługują synchronizację.
/// Dzięki niemu strategia/monitor może wołać `syncData()` niezależnie od implementacji.
abstract class SyncService {
  Future<void> syncData();
}