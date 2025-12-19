import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/remote/firebase_shopping_list_custom_item_service.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// 🔄 Synchronizuje niestandardowe elementy listy zakupów między lokalnym Hive a zdalnym Firestore
/// z uwzględnieniem wielu użytkowników (ownerUid + klucze z uid).
class ShoppingListCustomItemSyncService implements SyncService {
  final ShoppingListCustomItemRepository _remoteRepository;
  final FirebaseShoppingListCustomItemService _remoteService;
  final NetworkInfo _networkInfo;
  final FirebaseAuth _auth;

  ShoppingListCustomItemSyncService({
    required ShoppingListCustomItemRepository remoteRepository,
    required FirebaseShoppingListCustomItemService remoteService,
    required NetworkInfo networkInfo,
    FirebaseAuth? auth,
  })  : _remoteRepository = remoteRepository,
        _remoteService = remoteService,
        _networkInfo = networkInfo,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  Box<ShoppingListCustomItemModel> get _box =>
      Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

  bool _isMine(ShoppingListCustomItemModel m) =>
      m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  String _keyUid(ShoppingListCustomItemModel m) =>
      '${_uid}_${m.customItemId}';

  String _keyLegacy(ShoppingListCustomItemModel m) => m.customItemId;

  @override
  Future<Either<Failure, void>> syncData() async {
    if (!await _networkInfo.checkInternetConnection()) {
      return Left(NetworkFailure());
    }

    // === PUSH lokalnych zmian (tylko „moje”) ===
    final unsyncedModels =
        _box.values.where((m) => !m.isSynced && _isMine(m));

    final deletedModels = unsyncedModels.where((m) => m.isDeleted).toList();

    final nonDeletedUnsyncedModels =
        _deduplicate(unsyncedModels.where((m) => !m.isDeleted));

    final deletionFailure = await _syncDeletedModels(deletedModels);
    if (deletionFailure != null) return Left(deletionFailure);

    final addFailure = await _syncAdditions(nonDeletedUnsyncedModels);
    if (addFailure != null) return Left(addFailure);

    // === PULL z Firestore -> upsert do Hive ===
    final pullFailure = await _pullFromRemote();
    if (pullFailure != null) return Left(pullFailure);

    return const Right(null);
  }

  List<ShoppingListCustomItemModel> _deduplicate(
    Iterable<ShoppingListCustomItemModel> models,
  ) {
    final map = <String, ShoppingListCustomItemModel>{};
    for (final m in models) {
      map[_keyUid(m)] = m; // deduplikacja po kluczu z uid
    }
    return map.values.toList();
  }

  Future<Failure?> _syncDeletedModels(
    List<ShoppingListCustomItemModel> models,
  ) async {
    for (final m in models) {
      final result =
          await _remoteRepository.removeCustomItemFromShoppingList(
        m.customItemId,
      );

      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      // usuń lokalnie: nowy i legacy klucz
      await _box.delete(_keyUid(m));
      await _box.delete(_keyLegacy(m));
    }
    return null;
  }

  Future<Failure?> _syncAdditions(
    List<ShoppingListCustomItemModel> models,
  ) async {
    for (final m in models) {
      final entity = ShoppingListCustomItemMapper.toEntity(m);

      final result =
          await _remoteRepository.addCustomItemToShoppingList(entity);

      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      final enriched =
          m.copyWith(isSynced: true, isDeleted: false, ownerUid: _uid);

      await _box.put(_keyUid(enriched), enriched);

      // usuń ewentualny legacy klucz
      await _box.delete(_keyLegacy(enriched));
    }
    return null;
  }

  /// ⬇️ PULL z Firestore i zapis do Hive (multi-user)
  Future<Failure?> _pullFromRemote() async {
    try {
      final remoteItems =
          await _remoteService.getCustomItemFromShoppingList();

      for (final m in remoteItems.where((x) => !x.isDeleted)) {
        final enriched =
            m.copyWith(isSynced: true, isDeleted: false, ownerUid: _uid);

        await _box.put(_keyUid(enriched), enriched);

        // usuń ewentualny legacy klucz
        await _box.delete(_keyLegacy(enriched));
      }

      return null;
    } catch (_) {
      return NetworkFailure();
    }
  }

  Failure? _failureOrNull(Either<Failure, void> result) {
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }
}