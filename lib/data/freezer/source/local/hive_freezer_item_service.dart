import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/freezer/model/freezer_item_model.dart';
import 'package:mealapp/service_locator.dart';

abstract class HiveFreezerItemService {
  Future<List<FreezerItemModel>> getAll();
  Future<void> add(FreezerItemModel item);
  Future<void> remove(String itemId, {bool isOnline});
  Future<void> update(FreezerItemModel item);

  Future<List<FreezerItemModel>> getUnsyncedChanges();
  Future<void> markAsSynced(String itemId);
  Future<void> restore(FreezerItemModel item);
  Future<void> clearSyncedDeleted();
}

class HiveFreezerItemServiceImpl implements HiveFreezerItemService {
  HiveFreezerItemServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Box<FreezerItemModel> get _box => Hive.box<FreezerItemModel>('freezerItems');

  String get _uid => _auth.currentUser?.uid ?? '';
  bool _isMine(FreezerItemModel m) => m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty);

  String _keyUid(FreezerItemModel m) => '${_uid}_${m.itemId}';
  String _keyLegacy(FreezerItemModel m) => m.itemId;

  @override
  Future<List<FreezerItemModel>> getAll() async {
    final all = _box.values.toList();
    return all.where((x) => !x.isDeleted && _isMine(x)).toList();
  }

  @override
  Future<void> add(FreezerItemModel item) async {
    final enriched = item.copyWith(ownerUid: _uid, isSynced: false, isDeleted: false);
    await _box.put(_keyUid(enriched), enriched);
    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> update(FreezerItemModel item) async {
    final enriched = item.copyWith(ownerUid: _uid, isSynced: false, isDeleted: false);

    final kNew = _keyUid(enriched);
    final kOld = _keyLegacy(enriched);

    final existing = _box.get(kNew) ?? _box.get(kOld);
    final toSave = (existing ?? enriched).copyWith(
      name: enriched.name,
      category: enriched.category,
      ownerUid: _uid,
      isDeleted: false,
      isSynced: false,
    );

    await _box.put(kNew, toSave);
    await _box.delete(kOld);
    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> remove(String itemId, {bool isOnline = false}) async {
    final kNew = '${_uid}_$itemId';
    final kOld = itemId;
    final current = _box.get(kNew) ?? _box.get(kOld);

    if (current != null && _isMine(current)) {
      if (isOnline) {
        await _box.delete(kNew);
        await _box.delete(kOld);
      } else {
        final keyToUse = _box.get(kNew) != null ? kNew : kOld;
        await _box.put(keyToUse, current.copyWith(isDeleted: true, isSynced: false, ownerUid: _uid));
      }
    }

    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<List<FreezerItemModel>> getUnsyncedChanges() async {
    return _box.values.where((x) => !x.isSynced && _isMine(x)).toList();
  }

  @override
  Future<void> markAsSynced(String itemId) async {
    final kNew = '${_uid}_$itemId';
    final kOld = itemId;
    final m = _box.get(kNew) ?? _box.get(kOld);

    if (m == null || !_isMine(m)) return;

    final keyToUse = _box.get(kNew) != null ? kNew : kOld;
    await _box.put(keyToUse, m.copyWith(isSynced: true, ownerUid: _uid));

    if (keyToUse == kOld) {
      await _box.put(kNew, m.copyWith(isSynced: true, ownerUid: _uid));
      await _box.delete(kOld);
    }
  }

  @override
  Future<void> restore(FreezerItemModel item) async {
    final enriched = item.copyWith(ownerUid: _uid);
    final kNew = _keyUid(enriched);
    final existing = _box.get(kNew) ?? _box.get(_keyLegacy(enriched));

    final toSave = (existing ?? enriched).copyWith(
      isDeleted: false,
      isSynced: false,
      ownerUid: _uid,
      name: item.name,
      category: item.category,
    );

    await _box.put(kNew, toSave);
    await _box.delete(_keyLegacy(enriched));
    unawaited(sl<SyncStrategy>().onDataChanged());
  }

  @override
  Future<void> clearSyncedDeleted() async {
    final keys = _box.keys.where((k) {
      final m = _box.get(k);
      return m != null && m.isDeleted && m.isSynced && _isMine(m);
    }).toList();

    for (final k in keys) {
      await _box.delete(k);
    }
  }
}