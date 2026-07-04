import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/service_locator.dart';

abstract class HiveShoppingListCustomItemService {
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList();
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(
    String customItemId, {
    bool isOnline,
  });
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem();
  Future<void> markShoppingListCustomItemAsSynced(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getUnsyncedChangesForShoppingListCustomItem();
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> clearSyncedDeletedItems();
  Future<void> updateCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> clearAll({bool isOnline});
}

class HiveShoppingListCustomItemServiceImpl
    implements HiveShoppingListCustomItemService {
  HiveShoppingListCustomItemServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Box<ShoppingListCustomItemModel> get _box =>
      Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

  String get _uid => _auth.currentUser?.uid ?? '';

  String _keyUid(ShoppingListCustomItemModel item) => '${_uid}_${item.customItemId}';
  String _keyLegacy(ShoppingListCustomItemModel item) => item.customItemId;

  bool _isMine(ShoppingListCustomItemModel m) =>
      m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  @override
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList() async {
    final all = _box.values.toList();
    final mine = all.where((item) => !item.isDeleted && _isMine(item)).toList();

    debugLog(
      '🛒 HIVE getCustomItemFromShoppingList(): total=${all.length}, mine=${mine.length}, uid=$_uid',
      name: 'HiveCustomSL',
    );

    return mine;
  }

  @override
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    // jeśli item nie ma metadanych, ustaw jako “mój oryginał”
    final enriched = item.copyWith(
      ownerUid: _uid,
      isSynced: false,
      isDeleted: false,
      sourceOwnerUid: item.sourceOwnerUid.isNotEmpty ? item.sourceOwnerUid : _uid,
      sourceItemId: item.sourceItemId.isNotEmpty ? item.sourceItemId : item.customItemId,
      editors: item.editors.isNotEmpty ? item.editors : (_uid.isEmpty ? const [] : <String>[_uid]),
    );

    await _box.put(_keyUid(enriched), enriched);

    debugLog('✅ Dodano custom item: ${enriched.customItemName}', name: 'HiveCustomSL');
    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> updateCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    final enriched = item.copyWith(
      ownerUid: _uid,
      isDeleted: false,
      isSynced: false,
    );

    final kNew = _keyUid(enriched);
    final kOld = _keyLegacy(enriched);

    final existing = _box.get(kNew) ?? _box.get(kOld);

    // ✅ zachowaj metadane jeśli już były
    final toSave = (existing ?? enriched).copyWith(
      customItemName: enriched.customItemName,
      customItemCategory: enriched.customItemCategory,
      isChecked: enriched.isChecked,
      ownerUid: _uid,
      isDeleted: false,
      isSynced: false,
      sourceOwnerUid: (existing?.sourceOwnerUid.isNotEmpty == true)
          ? existing!.sourceOwnerUid
          : (enriched.sourceOwnerUid.isNotEmpty ? enriched.sourceOwnerUid : _uid),
      sourceItemId: (existing?.sourceItemId.isNotEmpty == true)
          ? existing!.sourceItemId
          : (enriched.sourceItemId.isNotEmpty ? enriched.sourceItemId : enriched.customItemId),
      editors: (existing?.editors.isNotEmpty == true)
          ? existing!.editors
          : (enriched.editors.isNotEmpty ? enriched.editors : (_uid.isEmpty ? const [] : <String>[_uid])),
    );

    await _box.put(kNew, toSave);
    await _box.delete(kOld);

    debugLog('✏️ Zaktualizowano custom item: ${toSave.customItemName} (key=$kNew)', name: 'HiveCustomSL');
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
        await _box.delete(kNew);
        await _box.delete(kOld);
      } else {
        final keyToUse = _box.get(kNew) != null ? kNew : kOld;
        await _box.put(
          keyToUse,
          current.copyWith(isDeleted: true, isSynced: false, ownerUid: _uid),
        );
      }
    }

    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<List<ShoppingListCustomItemModel>> getUnsyncedShoppingListCustomItem() async {
    return _box.values
        .where((item) => !item.isSynced && !item.isDeleted && _isMine(item))
        .toList();
  }

  @override
  Future<List<ShoppingListCustomItemModel>> getUnsyncedChangesForShoppingListCustomItem() async {
    return _box.values.where((item) => !item.isSynced && _isMine(item)).toList();
  }

  @override
  Future<void> markShoppingListCustomItemAsSynced(String customItemId) async {
    final kNew = '${_uid}_$customItemId';
    final kOld = customItemId;

    final model = _box.get(kNew) ?? _box.get(kOld);
    if (model == null || !_isMine(model)) return;

    final keyToUse = _box.get(kNew) != null ? kNew : kOld;

    await _box.put(
      keyToUse,
      model.copyWith(isSynced: true, ownerUid: _uid),
    );

    // migracja legacy -> uid key
    if (keyToUse == kOld) {
      await _box.put(
        kNew,
        model.copyWith(isSynced: true, ownerUid: _uid),
      );
      await _box.delete(kOld);
    }
  }

  @override
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    final enriched = item.copyWith(ownerUid: _uid);
    final kNew = _keyUid(enriched);
    final existing = _box.get(kNew) ?? _box.get(_keyLegacy(enriched));

    final modelToSave = (existing ?? enriched).copyWith(
      isDeleted: false,
      isSynced: false,
      ownerUid: _uid,
      customItemName: item.customItemName,
      customItemCategory: item.customItemCategory,
    );

    await _box.put(kNew, modelToSave);
    await _box.delete(_keyLegacy(enriched));

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
    }
  }

  @override
  Future<void> clearAll({bool isOnline = false}) async {
    final keys = _box.keys.toList();

    for (final key in keys) {
      final m = _box.get(key);
      if (m == null) continue;
      if (!_isMine(m)) continue;

      if (isOnline) {
        await _box.delete(key);
      } else {
        await _box.put(key, m.copyWith(isDeleted: true, isSynced: false, ownerUid: _uid));
      }
    }

    unawaited(sl<SyncStrategy>().onDataChanged());
  }
}