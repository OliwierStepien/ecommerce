import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/freezer/mapper/freezer_item_mapper.dart';
import 'package:mealapp/data/freezer/model/freezer_item_model.dart';
import 'package:mealapp/data/freezer/source/remote/firebase_freezer_item_service.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class FreezerItemSyncService implements SyncService {
  final FreezerItemRepository _remoteRepository;
  final FirebaseFreezerItemService _remoteService;
  final NetworkInfo _networkInfo;
  final FirebaseAuth _auth;

  FreezerItemSyncService({
    required FreezerItemRepository remoteRepository,
    required FirebaseFreezerItemService remoteService,
    required NetworkInfo networkInfo,
    FirebaseAuth? auth,
  })  : _remoteRepository = remoteRepository,
        _remoteService = remoteService,
        _networkInfo = networkInfo,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  Box<FreezerItemModel> get _box => Hive.box<FreezerItemModel>('freezerItems');

  bool _isMine(FreezerItemModel m) =>
      m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  String _keyUid(FreezerItemModel m) => '${_uid}_${m.itemId}';
  String _keyLegacy(FreezerItemModel m) => m.itemId;

  @override
  Future<Either<Failure, void>> syncData() async {
    if (!await _networkInfo.checkInternetConnection()) {
      return Left(NetworkFailure());
    }

    // === PUSH lokalnych zmian ===
    final unsynced = _box.values.where((m) => !m.isSynced && _isMine(m));

    final deleted = unsynced.where((m) => m.isDeleted).toList();
    final upserts = _deduplicate(unsynced.where((m) => !m.isDeleted));

    final delFail = await _syncDeleted(deleted);
    if (delFail != null) return Left(delFail);

    final upsertFail = await _syncUpserts(upserts);
    if (upsertFail != null) return Left(upsertFail);

    // === PULL z remote ===
    final pullFail = await _pullFromRemote();
    if (pullFail != null) return Left(pullFail);

    return const Right(null);
  }

  List<FreezerItemModel> _deduplicate(Iterable<FreezerItemModel> models) {
    final map = <String, FreezerItemModel>{};
    for (final m in models) {
      map[_keyUid(m)] = m;
    }
    return map.values.toList();
  }

  Future<Failure?> _syncDeleted(List<FreezerItemModel> models) async {
    for (final m in models) {
      final res = await _remoteRepository.remove(m.itemId);
      final fail = _failureOrNull(res);
      if (fail != null) return fail;

      await _box.delete(_keyUid(m));
      await _box.delete(_keyLegacy(m));
    }
    return null;
  }

  Future<Failure?> _syncUpserts(List<FreezerItemModel> models) async {
    for (final m in models) {
      final entity = FreezerItemMapper.toEntity(m);
      // upsert jako add (tak jak w shopping list)
      final res = await _remoteRepository.add(entity);

      final fail = _failureOrNull(res);
      if (fail != null) return fail;

      final enriched = m.copyWith(
        isSynced: true,
        isDeleted: false,
        ownerUid: _uid,
      );

      await _box.put(_keyUid(enriched), enriched);
      await _box.delete(_keyLegacy(enriched));
    }
    return null;
  }

  Future<Failure?> _pullFromRemote() async {
    try {
      final remoteItems = await _remoteService.getAll();

      for (final m in remoteItems.where((x) => !x.isDeleted)) {
        final enriched = m.copyWith(
          isSynced: true,
          isDeleted: false,
          ownerUid: _uid,
        );

        await _box.put(_keyUid(enriched), enriched);
        await _box.delete(_keyLegacy(enriched));
      }
      return null;
    } catch (_) {
      return NetworkFailure();
    }
  }

  Failure? _failureOrNull(Either<Failure, void> result) {
    return result.fold((f) => f, (_) => null);
    }
}