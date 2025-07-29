import 'package:hive/hive.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';

/// Abstrakcyjny serwis – definiuje interfejs operacji na niestandardowych składnikach listy zakupów.
/// Implementacja może być lokalna (Hive), zdalna (Firestore), itp.
abstract class HiveShoppingListCustomItemService {
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList();
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(String customItemId,
      {bool isOnline});
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem();
  Future<void> markShoppingListCustomItemAsSynced(String customItemId);
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedChangesForShoppingListCustomItem();
  Future<void> restoreCustomItemToShoppingList(
      ShoppingListCustomItemModel item);
  Future<void> clearSyncedDeletedItems();
}

/// Implementacja serwisu przy użyciu lokalnej bazy danych Hive
class HiveShoppingListCustomItemServiceImpl
    implements HiveShoppingListCustomItemService {
  /// Uzyskuje referencję do lokalnego Hive boxa przechowującego niestandardowe składniki listy zakupów
  Box<ShoppingListCustomItemModel> get _box =>
      Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

  @override
  Future<List<ShoppingListCustomItemModel>>
      getCustomItemFromShoppingList() async {
    // Zwraca wszystkie elementy z boxa, które nie są oznaczone jako usunięte
    return _box.values.where((item) => !item.isDeleted).toList();
  }

  @override
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    // Dodaje nowy składnik lub nadpisuje istniejący o tym samym ID, upewniając się, że isDeleted = false

    final model = _box.get(item.customItemId);

    await _box.put(
      item.customItemId,
      item.copyWith(
        isDeleted: false,
        isSynced: model?.isSynced ?? false,
      ),
    );

    // Pobiera aktualną listę widocznych składników, aby zarejestrować ich liczbę
    final items = await getCustomItemFromShoppingList();

    // Logi informacyjne (debugLog zamiast print)
    debugLog('✅ Dodano własny składnik: ${item.customItemName}',
        name: 'HiveService');
    debugLog('🛒 Liczba własnych składników: ${items.length}',
        name: 'HiveService');
  }

  @override
  Future<void> removeCustomItemFromShoppingList(String customItemId,
      {bool isOnline = false}) async {
    // Pobiera składnik po ID
    final item = _box.get(customItemId);

    if (item != null) {
      if (isOnline) {
        // Jeśli jest już zsynchronizowany z backendem – usuń go całkowicie z Hive
        await _box.delete(customItemId);
        debugLog('🗑️ Trwale usunięto zsynchronizowany składnik: $customItemId',
            name: 'HiveService');
      } else {
        // W przeciwnym razie oznacz jako usunięty i niezsynchronizowany – do późniejszej synchronizacji
        await _box.put(
          customItemId,
          item.copyWith(isDeleted: true, isSynced: false),
        );
        debugLog('❌ Oznaczono jako usunięty: ${item.customItemName}',
            name: 'HiveService');
      }
    }
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedShoppingListCustomItem() async {
    // Zwraca składniki, które zostały dodane/zmienione lokalnie, ale jeszcze nie zsynchronizowane i nie są usunięte
    return _box.values
        .where((item) => !item.isSynced && !item.isDeleted)
        .toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedChangesForShoppingListCustomItem() async {
    // Zwraca WSZYSTKIE zmiany lokalne: niezsynchronizowane (dodane, zmienione lub usunięte)
    return _box.values.where((item) => !item.isSynced).toList();
  }

  @override
  Future<void> markShoppingListCustomItemAsSynced(String customItemId) async {
    // Pobiera składnik po ID
    final model = _box.get(customItemId);

    if (model != null) {
      // Ustawia flagę isSynced = true, co oznacza, że element został wysłany do backendu
      await _box.put(
        customItemId,
        model.copyWith(isSynced: true),
      );
      debugLog('✅ Zaznaczono jako zsynchronizowany: ${model.customItemName}',
          name: 'HiveService');
    }
  }

  @override
  Future<void> restoreCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    // Sprawdza, czy składnik istnieje już w Hive
    final model = _box.get(item.customItemId);

    // Tworzy obiekt do zapisania:
    // - jeśli istnieje: oznacza jako nieusunięty
    // - jeśli nie: dodaje nowy, nieusunięty i niezsynchronizowany
    final toSave = model != null
        ? model.copyWith(isDeleted: false)
        : item.copyWith(isDeleted: false, isSynced: false);

    // Zapisuje składnik do Hive
    await _box.put(item.customItemId, toSave);

    // Pobiera pełną listę składników i dzieli na aktywne i usunięte – do celów statystyki/debug
    final allItems = _box.values.toList();
    final activeItems = allItems.where((i) => !i.isDeleted).toList();
    final deletedItems = allItems.where((i) => i.isDeleted).toList();

    debugLog('♻️ Przywrócono składnik: ${item.customItemName}',
        name: 'HiveService');
    debugLog('📦 Ilość wpisów w Hive: ${allItems.length}', name: 'HiveService');
    debugLog(
        '🛒 Aktywne: ${activeItems.length}, 🗑️ Usunięte: ${deletedItems.length}',
        name: 'HiveService');
  }

  @override
  Future<void> clearSyncedDeletedItems() async {
    // Szuka kluczy elementów, które zostały oznaczone jako usunięte i są zsynchronizowane z backendem
    final keysToDelete = _box.keys.where((key) {
      final item = _box.get(key);
      return item != null && item.isDeleted && item.isSynced;
    }).toList();

    // Trwale usuwa każdy taki element z Hive
    for (final key in keysToDelete) {
      await _box.delete(key);
      debugLog('🧹 Usunięto trwale zsynchronizowany składnik: $key',
          name: 'HiveService');
    }
  }
}
