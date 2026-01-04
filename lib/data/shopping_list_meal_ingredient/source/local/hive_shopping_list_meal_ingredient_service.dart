// data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/service_locator.dart';

abstract class HiveShoppingListMealIngredientService {
  Future<List<ShoppingListMealIngredientModel>>
      getMealIngredientFromShoppingList();
  Future<void> addMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item);
  Future<void> removeMealIngredientFromShoppingList(
    ShoppingListMealIngredientModel item, {
    bool isOnline = false,
  });
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedShoppingListMealIngredient();
  Future<void> markShoppingListMealIngredientAsSynced(
      String mealId, String ingredientId);
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedChangesForShoppingListMealIngredient();
  Future<void> restoreMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item);
  Future<void> clearSyncedDeletedItems();
  Future<void> clearAll({bool isOnline});
}

class HiveShoppingListMealIngredientServiceImpl
    implements HiveShoppingListMealIngredientService {
  HiveShoppingListMealIngredientServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Box<ShoppingListMealIngredientModel> get _box =>
      Hive.box<ShoppingListMealIngredientModel>('shoppingListMealIngredients');

  String get _uid => _auth.currentUser?.uid ?? '';

  String _keyUid(ShoppingListMealIngredientModel item) =>
      '${_uid}_${item.meal.mealId}_${item.ingredient.ingredientId}';

  String _keyLegacy(ShoppingListMealIngredientModel item) =>
      '${item.meal.mealId}_${item.ingredient.ingredientId}';

  bool _isMine(ShoppingListMealIngredientModel m) =>
      m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getMealIngredientFromShoppingList() async {
    final all = _box.values.toList();
    final mine =
        all.where((model) => !model.isDeleted && _isMine(model)).toList();
    debugLog(
        '🛒 HIVE getMealIngredientFromShoppingList(): total=${all.length}, mine=${mine.length}, uid=$_uid',
        name: 'HiveSL');
    return mine;
  }

  @override
  Future<void> addMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item) async {
    final enriched =
        item.copyWith(ownerUid: _uid, isSynced: false, isDeleted: false);
    final key = _keyUid(enriched);

    await _box.put(key, enriched);

    final allIngredients = await getMealIngredientFromShoppingList();
    debugLog(
        '✅ Dodano składnik: ${item.ingredient.ingredientName} (posiłek: ${item.meal.title})',
        name: 'HiveSL');
    debugLog('🛒 Liczba składników (mine): ${allIngredients.length}',
        name: 'HiveSL');

    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> removeMealIngredientFromShoppingList(
    ShoppingListMealIngredientModel item, {
    bool isOnline = false,
  }) async {
    // próbuj po nowym kluczu, w razie czego po legacy
    final enriched = item.copyWith(ownerUid: _uid);
    final kNew = _keyUid(enriched);
    final kOld = _keyLegacy(enriched);

    final current = _box.get(kNew) ?? _box.get(kOld);

    if (current != null) {
      if (isOnline) {
        await _box.delete(kNew);
        await _box.delete(kOld);
        debugLog('🗑️ HIVE delete permanent (online): key=$kNew|$kOld',
            name: 'HiveSL');
      } else {
        await _box.put(
          current == _box.get(kNew) ? kNew : kOld,
          current.copyWith(isSynced: false, isDeleted: true, ownerUid: _uid),
        );
        debugLog(
            '❌ HIVE mark deleted (local): key=${current == _box.get(kNew) ? kNew : kOld}',
            name: 'HiveSL');
      }
    }

    final allIngredients = await getMealIngredientFromShoppingList();
    debugLog(
        '🛒 Liczba składników (mine) po usunięciu: ${allIngredients.length}',
        name: 'HiveSL');

    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedShoppingListMealIngredient() async {
    return _box.values
        .where((m) => !m.isSynced && !m.isDeleted && _isMine(m))
        .toList();
  }

  @override
  Future<List<ShoppingListMealIngredientModel>>
      getUnsyncedChangesForShoppingListMealIngredient() async {
    return _box.values.where((m) => !m.isSynced && _isMine(m)).toList();
  }

  @override
  Future<void> markShoppingListMealIngredientAsSynced(
      String mealId, String ingredientId) async {
    final kNew = '${_uid}_${mealId}_$ingredientId';
    final kOld = '${mealId}_$ingredientId';

    final model = _box.get(kNew) ?? _box.get(kOld);
    if (model != null) {
      final keyToUse = _box.get(kNew) != null ? kNew : kOld;
      await _box.put(keyToUse, model.copyWith(isSynced: true, ownerUid: _uid));
      debugLog('✅ Zaznaczono jako synced: $ingredientId (meal: $mealId)',
          name: 'HiveSL');
      // jeśli to był legacy klucz, przepisz pod nowy i usuń stary
      if (keyToUse == kOld) {
        await _box.put(kNew, (model.copyWith(isSynced: true, ownerUid: _uid)));
        await _box.delete(kOld);
        debugLog('🔁 Migrated legacy -> uid key: $kOld -> $kNew',
            name: 'HiveSL');
      }
    }
  }

  @override
  Future<void> restoreMealIngredientToShoppingList(
      ShoppingListMealIngredientModel item) async {
    final enriched = item.copyWith(ownerUid: _uid);
    final kNew = _keyUid(enriched);
    final existing = _box.get(kNew) ?? _box.get(_keyLegacy(enriched));

    final modelToSave = (existing ?? enriched).copyWith(
      isDeleted: false,
      isSynced: false, // po restore – do synchronizacji
      ownerUid: _uid,
      portionCount: item.portionCount,
    );

    await _box.put(kNew, modelToSave);
    if (existing != null && _box.containsKey(_keyLegacy(enriched))) {
      await _box.delete(_keyLegacy(enriched));
    }

    final allIngredients = await getMealIngredientFromShoppingList();
    debugLog(
        '♻️ Przywrócono: ${item.ingredient.ingredientName} (posiłek: ${item.meal.title})',
        name: 'HiveSL');
    debugLog('🛒 Liczba składników (mine): ${allIngredients.length}',
        name: 'HiveSL');

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
      debugLog('🧹 Usunięto trwale zsynchronizowany składnik: $key',
          name: 'HiveSL');
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
        await _box.put(
          key,
          m.copyWith(isDeleted: true, isSynced: false, ownerUid: _uid),
        );
      }
    }

    unawaited(sl<SyncStrategy>().onDataChanged());
  }
}
