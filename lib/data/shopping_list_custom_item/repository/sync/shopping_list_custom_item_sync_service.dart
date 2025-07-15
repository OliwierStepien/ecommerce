import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// Synchronizuje niestandardowe elementy listy zakupów między Hive a Firestore.
/// Proces:
/// 1. Sprawdzenie internetu
/// 2. Usuwanie pozycji oznaczonych jako `isDeleted`
/// 3. Dodanie lub aktualizacja pozostałych
/// 4. Oznaczenie ich jako zsynchronizowanych (`isSynced`)
class ShoppingListCustomItemSyncService implements SyncService {
  final ShoppingListCustomItemRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  ShoppingListCustomItemSyncService({
    required ShoppingListCustomItemRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> syncData() async {
    // 1) Sprawdź internet
    if (!await _networkInfo.checkInternetConnection()) {
      return Left(NetworkFailure());
    }

    // 2) Pobierz niesynchronizowane modele
    final box = Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');
    final unsyncedModels = box.values.where((m) => !m.isSynced);

    final deletedModels = unsyncedModels.where((m) => m.isDeleted).toList();
    final nonDeletedModels = _deduplicate(unsyncedModels.where((m) => !m.isDeleted));

    // 3) Usuń modele oznaczone jako usunięte
    final deletionFailure = await _syncDeletedModels(deletedModels, box);
    if (deletionFailure != null) return Left(deletionFailure);

    // 4) Dodaj/aktualizuj pozostałe
    final addFailure = await _syncAdditions(nonDeletedModels, box);
    if (addFailure != null) return Left(addFailure);

    return const Right(null);
  }

  /* ---------- POMOCNICZE ---------- */

  String _modelKey(ShoppingListCustomItemModel m) => m.customItemId;

  List<ShoppingListCustomItemModel> _deduplicate(
    Iterable<ShoppingListCustomItemModel> models,
  ) {
    final map = <String, ShoppingListCustomItemModel>{};
    for (final m in models) {
      map[_modelKey(m)] = m;
    }
    return map.values.toList();
  }

  Future<Failure?> _syncDeletedModels(
    List<ShoppingListCustomItemModel> models,
    Box<ShoppingListCustomItemModel> box,
  ) async {
    for (final m in models) {
      final result =
          await _remoteRepository.removeCustomItemFromShoppingList(m.customItemId);

      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      await box.delete(_modelKey(m));
    }
    return null;
  }

  Future<Failure?> _syncAdditions(
    List<ShoppingListCustomItemModel> models,
    Box<ShoppingListCustomItemModel> box,
  ) async {
    for (final m in models) {
      final entity = ShoppingListCustomItemMapper.toEntity(m);

      final result = await _remoteRepository.addCustomItemToShoppingList(entity);

      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      await box.put(
        _modelKey(m),
        m.copyWith(isSynced: true, isDeleted: false),
      );
    }
    return null;
  }

  Failure? _failureOrNull(Either<Failure, void> result) {
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }
}