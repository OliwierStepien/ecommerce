import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

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

  @override
  Future<Either<Failure, void>> addCustomItemToShoppingList(
      ShoppingListCustomItemEntity customItem) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository.addCustomItemToShoppingList(customItem);
    
    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remoteRepository.addCustomItemToShoppingList(customItem);
        
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository.markShoppingListCustomItemAsSynced(customItem.customItemId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId) async {
    // 1. Najpierw lokalna operacja
    final localResult = await _localRepository.removeCustomItemFromShoppingList(customItemId);
    
    return await localResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 2. Próba synchronizacji jeśli online
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remoteRepository.removeCustomItemFromShoppingList(customItemId);
        
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _localRepository.markShoppingListCustomItemAsSynced(customItemId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>> getCustomItemToShoppingList() async {
    return await _localRepository.getCustomItemToShoppingList();
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>> getUnsyncedShoppingListCustomItem() async {
    return await _localRepository.getUnsyncedShoppingListCustomItem();
  }

  @override
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
      String customItemId) async {
    return await _localRepository.markShoppingListCustomItemAsSynced(customItemId);
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>> 
      getUnsyncedChangesForShoppingListCustomItem() async {
    return await _localRepository.getUnsyncedChangesForShoppingListCustomItem();
  }
}