import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/service_locator.dart';

class SyncController {
  final List<SyncService> _services;

  SyncController(this._services);

  Future<void> syncAll() async {
    for (final service in _services) {
      await service.syncData();
    }

    // Usuwanie zsynchronizowanych usuniętych wpisów
    await sl<HiveShoppingListMealIngredientService>().clearSyncedDeletedItems();
  }
}