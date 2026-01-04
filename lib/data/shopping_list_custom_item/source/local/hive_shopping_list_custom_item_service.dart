import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/service_locator.dart';

/// Abstrakcyjny serwis – definiuje interfejs operacji na niestandardowych składnikach listy zakupów.
/// Implementacja może być lokalna (Hive), zdalna (Firestore), itp.
abstract class HiveShoppingListCustomItemService {
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList();
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(
    String customItemId, {
    bool isOnline,
  });
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem();
  Future<void> markShoppingListCustomItemAsSynced(String customItemId);
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedChangesForShoppingListCustomItem();
  Future<void> restoreCustomItemToShoppingList(
      ShoppingListCustomItemModel item);
  Future<void> clearSyncedDeletedItems();
  Future<void> updateCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> clearAll({bool isOnline});
}

/// Implementacja serwisu przy użyciu lokalnej bazy danych Hive
class HiveShoppingListCustomItemServiceImpl
    implements HiveShoppingListCustomItemService {
  HiveShoppingListCustomItemServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Uzyskuje referencję do lokalnego Hive boxa przechowującego niestandardowe składniki listy zakupów
  Box<ShoppingListCustomItemModel> get _box =>
      Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

  String get _uid => _auth.currentUser?.uid ?? '';

  String _keyUid(ShoppingListCustomItemModel item) =>
      '${_uid}_${item.customItemId}';

  String _keyLegacy(ShoppingListCustomItemModel item) => item.customItemId;

  bool _isMine(ShoppingListCustomItemModel m) =>
      m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  @override
  Future<List<ShoppingListCustomItemModel>>
      getCustomItemFromShoppingList() async {
    final all = _box.values.toList();
    final mine = all.where((item) => !item.isDeleted && _isMine(item)).toList();

    debugLog(
      '🛒 HIVE getCustomItemFromShoppingList(): total=${all.length}, mine=${mine.length}, uid=$_uid',
      name: 'HiveCustomSL',
    );

    return mine;
  }

  @override
  Future<void> addCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    // Dodajemy/aktualizujemy wpis jako mój (ownerUid = _uid)
    final enriched = item.copyWith(
      ownerUid: _uid,
      isSynced: false,
      isDeleted: false,
    );

    final key = _keyUid(enriched);
    await _box.put(key, enriched);

    final items = await getCustomItemFromShoppingList();

    debugLog(
      '✅ Dodano własny składnik: ${item.customItemName}',
      name: 'HiveCustomSL',
    );
    debugLog(
      '🛒 Liczba własnych składników (mine): ${items.length}',
      name: 'HiveCustomSL',
    );

    // uruchom strategię synchronizacji
    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> removeCustomItemFromShoppingList(
    String customItemId, {
    bool isOnline = false,
  }) async {
    final kNew = '${_uid}_$customItemId';
    final kOld = customItemId;

    final current = _box.get(kNew) ?? _box.get(kOld);

    if (current != null && _isMine(current)) {
      if (isOnline) {
        // przy usuwaniu online czyścimy oba klucze
        await _box.delete(kNew);
        await _box.delete(kOld);
        debugLog(
          '🗑️ Trwale usunięto (online) własny składnik: $customItemId (keys: $kNew|$kOld)',
          name: 'HiveCustomSL',
        );
      } else {
        // lokalnie oznaczamy jako usunięty i niezsynchronizowany
        final keyToUse = _box.get(kNew) != null ? kNew : kOld;
        await _box.put(
          keyToUse,
          current.copyWith(
            isDeleted: true,
            isSynced: false,
            ownerUid: _uid,
          ),
        );
        debugLog(
          '❌ Oznaczono jako usunięty (local): $customItemId (key=$keyToUse)',
          name: 'HiveCustomSL',
        );
      }
    }

    final items = await getCustomItemFromShoppingList();
    debugLog(
      '🛒 Liczba własnych składników (mine) po usunięciu: ${items.length}',
      name: 'HiveCustomSL',
    );

    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedShoppingListCustomItem() async {
    return _box.values
        .where(
          (item) => !item.isSynced && !item.isDeleted && _isMine(item),
        )
        .toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>>
      getUnsyncedChangesForShoppingListCustomItem() async {
    return _box.values
        .where((item) => !item.isSynced && _isMine(item))
        .toList();
  }

  @override
  Future<void> markShoppingListCustomItemAsSynced(String customItemId) async {
    final kNew = '${_uid}_$customItemId';
    final kOld = customItemId;

    final model = _box.get(kNew) ?? _box.get(kOld);

    if (model != null && _isMine(model)) {
      final keyToUse = _box.get(kNew) != null ? kNew : kOld;

      await _box.put(
        keyToUse,
        model.copyWith(isSynced: true, ownerUid: _uid),
      );

      debugLog(
        '✅ Zaznaczono jako zsynchronizowany: ${model.customItemName} (key=$keyToUse)',
        name: 'HiveCustomSL',
      );

      // migracja legacy -> uid key
      if (keyToUse == kOld) {
        await _box.put(
          kNew,
          model.copyWith(isSynced: true, ownerUid: _uid),
        );
        await _box.delete(kOld);
        debugLog(
          '🔁 Migrated legacy -> uid key: $kOld -> $kNew',
          name: 'HiveCustomSL',
        );
      }
    }
  }

  @override
  Future<void> restoreCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    final enriched = item.copyWith(ownerUid: _uid);
    final kNew = _keyUid(enriched);
    final existing = _box.get(kNew) ?? _box.get(_keyLegacy(enriched));

    final modelToSave = (existing ?? enriched).copyWith(
      isDeleted: false,
      isSynced: false, // po restore – do synchronizacji
      ownerUid: _uid,
      customItemName: item.customItemName,
      customItemCategory: item.customItemCategory,
    );

    await _box.put(kNew, modelToSave);

    if (existing != null && _box.containsKey(_keyLegacy(enriched))) {
      await _box.delete(_keyLegacy(enriched));
    }

    final allItems = _box.values.toList();
    final activeItems =
        allItems.where((i) => !i.isDeleted && _isMine(i)).toList();
    final deletedItems =
        allItems.where((i) => i.isDeleted && _isMine(i)).toList();

    debugLog(
      '♻️ Przywrócono składnik: ${item.customItemName}',
      name: 'HiveCustomSL',
    );
    debugLog(
      '📦 Ilość wpisów w Hive (all): ${allItems.length}',
      name: 'HiveCustomSL',
    );
    debugLog(
      '🛒 Aktywne (mine): ${activeItems.length}, 🗑️ Usunięte (mine): ${deletedItems.length}',
      name: 'HiveCustomSL',
    );

    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> clearSyncedDeletedItems() async {
    final keysToDelete = _box.keys.where((key) {
      final item = _box.get(key);
      return item != null && item.isDeleted && item.isSynced && _isMine(item);
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
      debugLog(
        '🧹 Usunięto trwale zsynchronizowany własny składnik: $key',
        name: 'HiveCustomSL',
      );
    }
  }

  @override
  Future<void> updateCustomItemToShoppingList(
      ShoppingListCustomItemModel item) async {
    final enriched = item.copyWith(
      ownerUid: _uid,
      isDeleted: false,
      isSynced: false,
    );

    final kNew = _keyUid(enriched);
    final kOld = _keyLegacy(enriched);

    final existing = _box.get(kNew) ?? _box.get(kOld);

    // Jeśli istnieje, aktualizujemy tylko pola “biznesowe” + metadane sync
    final toSave = (existing ?? enriched).copyWith(
      customItemName: enriched.customItemName,
      customItemCategory: enriched.customItemCategory,
      ownerUid: _uid,
      isDeleted: false,
      isSynced: false,
    );

    await _box.put(kNew, toSave);
    await _box.delete(kOld); // migracja legacy -> uid key

    debugLog(
        '✏️ Zaktualizowano custom item: ${toSave.customItemName} (key=$kNew)',
        name: 'HiveCustomSL');
    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> clearAll({bool isOnline = false}) async {
    final keys = _box.keys.toList();

    for (final key in keys) {
      final m = _box.get(key);
      if (m == null) continue;
      if (!_isMine(m)) continue;

      if (isOnline) {
        // po udanym bulk delete w FS czyścimy twardo
        await _box.delete(key);
      } else {
        // offline: oznacz jako deleted, do późniejszego sync
        await _box.put(
          key,
          m.copyWith(isDeleted: true, isSynced: false, ownerUid: _uid),
        );
      }
    }

    unawaited(sl<SyncStrategy>().onDataChanged());
  }
}
