import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// Manager repozytoriów dla własnych pozycji listy zakupów.
/// Łączy lokalne i zdalne źródło danych.
/// Zawsze najpierw zapisuje lokalnie (Hive), a jeśli jest internet — synchronizuje z Firestore.
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
    // 1) Najpierw próbujemy zapisać lokalnie (Hive)
    final localResult =
        await _localRepository.addCustomItemToShoppingList(customItem);

    return localResult.fold(
      // Jeśli lokalnie się nie udało — kończymy od razu, zwracając Left z błędem.
      (failure) => Left(failure),
      (success) async {
        // 2) Jeśli lokalnie się udało — sprawdzamy, czy mamy połączenie z internetem
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) {
          return const Right(
              null); // Brak internetu → koniec (zsynchronizujemy później)
        }

        // 3) Próbujemy zsynchronizować z Firestore
        final remoteResult =
            await _remoteRepository.addCustomItemToShoppingList(customItem);

        return remoteResult.fold(
          // Jeśli Firestore się nie udało — kończymy, ale nie traktujemy tego jako błąd aplikacji
          // (bo Hive już ma dane, zsynchronizujemy później).
          (failure) => const Right(null),
          (success) async {
            // 4) Jeśli się udało — oznaczamy element jako zsynchronizowany lokalnie
            await _localRepository
                .markShoppingListCustomItemAsSynced(customItem.customItemId);
            return const Right(null); // pełen sukces
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId) async {
    // 1) Najpierw lokalne oznaczenie jako usunięte (lub fizyczne usunięcie z Hive)
    final localResult =
        await _localRepository.removeCustomItemFromShoppingList(customItemId);

    return localResult.fold(
      (failure) => Left(failure), // Jeśli się nie udało — zwróć błąd
      (success) async {
        // 2) Synchronizacja zdalna tylko jeśli jest internet
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        // 3) Próbujemy usunąć z Firestore
        final remoteResult =
            await _remoteRepository.removeCustomItemFromShoppingList(
          customItemId,
        );

        return remoteResult.fold(
          (failure) =>
              const Right(null), // brak błędu — zsynchronizujemy później
          (success) async {
            // 4) Po sukcesie oznaczamy w Hive jako zsynchronizowane (albo usuwamy z Hive na stałe)
            await _localRepository
                .markShoppingListCustomItemAsSynced(customItemId);
            return const Right(null);
          },
        );
      },
    );
  }

  /// 🔄 Przywracanie usuniętego elementu listy zakupów (lokalnie + zdalnie)
  @override
  Future<Either<Failure, void>> restoreCustomItemToShoppingList(
      ShoppingListCustomItemEntity customItem) async {
    // 1) Najpierw przywrócenie lokalnie (ustawienie isDeleted=false w Hive)
    final localResult =
        await _localRepository.restoreCustomItemToShoppingList(customItem);

    return localResult.fold(
      (failure) => Left(failure),
      (success) async {
        // 2) Jeśli jest internet — synchronizujemy również do Firestore
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult =
            await _remoteRepository.restoreCustomItemToShoppingList(customItem);

        return remoteResult.fold(
          (failure) =>
              const Right(null), // jeśli się nie uda — zsynchronizujemy później
          (success) async {
            // 3) Po udanym restore — oznaczamy lokalnie jako zsynchronizowane
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
          _localRepository.getCustomItemToShoppingList(); // tylko lokalny cache

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedShoppingListCustomItem() => _localRepository
          .getUnsyncedShoppingListCustomItem(); // do sync service

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedChangesForShoppingListCustomItem() =>
          _localRepository.getUnsyncedChangesForShoppingListCustomItem();

  @override
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
          String customItemId) =>
      _localRepository
          .markShoppingListCustomItemAsSynced(customItemId); // do sync service
          
  @override
  Future<Either<Failure, void>> updateCustomItemToShoppingList(
    ShoppingListCustomItemEntity customItem,
  ) async {
    final localResult =
        await _localRepository.updateCustomItemToShoppingList(customItem);

    return localResult.fold(
      (failure) => Left(failure),
      (_) async {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult =
            await _remoteRepository.updateCustomItemToShoppingList(customItem);

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
}
