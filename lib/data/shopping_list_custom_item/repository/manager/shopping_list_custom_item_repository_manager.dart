import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// Manager repozytoriów dla własnych pozycji listy zakupów.
/// Zapewnia zapis lokalny (Hive) + opcjonalną synchronizację zdalną (Firestore),
/// dokładnie w ten sam sposób jak dla składników posiłków.
class ShoppingListCustomItemRepositoryManager
    implements ShoppingListCustomItemRepository {
  final ShoppingListCustomItemRepository _localRepository;
  final ShoppingListCustomItemRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  ShoppingListCustomItemRepositoryManager({
    required ShoppingListCustomItemRepository localRepository,
    required ShoppingListCustomItemRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  /* ------------ Operacje CRUD + SYNC ------------ */

  @override
  Future<Either<Failure, void>> addCustomItemToShoppingList(
      ShoppingListCustomItemEntity customItem) async {
    // 1) lokalny zapis
    final localResult =
        await _localRepository.addCustomItemToShoppingList(customItem);

    return localResult.fold(
      Left.new,
      (_) async {
        // 2) próba zdalnej synchronizacji
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult =
            await _remoteRepository.addCustomItemToShoppingList(customItem);

        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository
                .markShoppingListCustomItemAsSynced(customItem.customItemId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId) async {
    // 1) lokalnie
    final localResult =
        await _localRepository.removeCustomItemFromShoppingList(customItemId);

    return localResult.fold(
      Left.new,
      (_) async {
        // 2) online?
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult =
            await _remoteRepository.removeCustomItemFromShoppingList(
          customItemId,
        );

        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository
                .markShoppingListCustomItemAsSynced(customItemId);
            return const Right(null);
          },
        );
      },
    );
  }

  /// 🔄 NOWA METODA – przywracanie usuniętego elementu
  @override
  Future<Either<Failure, void>> restoreCustomItemToShoppingList(
      ShoppingListCustomItemEntity customItem) async {
    // 1) lokalny restore
    final localResult = await _localRepository
        .restoreCustomItemToShoppingList(customItem);

    return localResult.fold(
      Left.new,
      (_) async {
        // 2) synchronizacja zdalna (jeśli online)
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult =
            await _remoteRepository.restoreCustomItemToShoppingList(customItem);

        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository
                .markShoppingListCustomItemAsSynced(customItem.customItemId);
            return const Right(null);
          },
        );
      },
    );
  }

  /* ------------ Odczyt i praca na lokalnym cache'u ------------ */

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getCustomItemToShoppingList() =>
          _localRepository.getCustomItemToShoppingList();

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedShoppingListCustomItem() =>
          _localRepository.getUnsyncedShoppingListCustomItem();

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedChangesForShoppingListCustomItem() =>
          _localRepository.getUnsyncedChangesForShoppingListCustomItem();

  @override
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
          String customItemId) =>
      _localRepository.markShoppingListCustomItemAsSynced(customItemId);
}