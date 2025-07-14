import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/network/sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

class ShoppingListCustomItemSyncService implements SyncService {
  final ShoppingListCustomItemRepository _remoteRepository;
  final HiveShoppingListCustomItemService _hiveService;
  final NetworkInfo _networkInfo;

  ShoppingListCustomItemSyncService({
    required ShoppingListCustomItemRepository remoteRepository,
    required HiveShoppingListCustomItemService hiveService,
    required NetworkInfo networkInfo,
  })  : _remoteRepository = remoteRepository,
        _hiveService = hiveService,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> syncData() async {
    final isOnline = await _networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure());
    }

    // Pobierz niesynchronizowane zmiany z Hive
    final unsyncedModels = await _hiveService.getUnsyncedChangesForShoppingListCustomItem();

    // Najpierw usuń wszystkie oznaczone do usunięcia
    final modelsToDelete = unsyncedModels.where((model) => model.isDeleted);
    for (final model in modelsToDelete) {
      final result = await _remoteRepository.removeCustomItemFromShoppingList(
        model.customItemId,
      );
      if (result.isLeft()) return Left((result as Left).value);
      
      await _hiveService.removeCustomItemFromShoppingList(
        model.customItemId,
        isOnline: true,
      );
    }

    // Następnie dodaj/aktualizuj nowe elementy
    final modelsToAddOrUpdate = unsyncedModels.where((model) => !model.isDeleted);
    for (final model in modelsToAddOrUpdate) {
      final entity = ShoppingListCustomItemMapper.toEntity(model);
      
      // Najpierw usuń istniejący element (jeśli istnieje) aby uniknąć duplikatów
      final removeResult = await _remoteRepository.removeCustomItemFromShoppingList(
        model.customItemId,
      );
      if (removeResult.isLeft()) return Left((removeResult as Left).value);

      // Następnie dodaj nową wersję
      final addResult = await _remoteRepository.addCustomItemToShoppingList(entity);
      if (addResult.isLeft()) return Left((addResult as Left).value);

      // Oznacz jako zsynchronizowany
      await _hiveService.markShoppingListCustomItemAsSynced(model.customItemId);
    }

    return const Right(null);
  }
}