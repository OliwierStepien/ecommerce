import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';

class FreezerItemRepositoryManager implements FreezerItemRepository {
  final FreezerItemRepository _local;
  final FreezerItemRepository _remote;
  final NetworkInfo _networkInfo;

  FreezerItemRepositoryManager({
    required FreezerItemRepository localRepository,
    required FreezerItemRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _local = localRepository,
        _remote = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> add(FreezerItemEntity item) async {
    final localResult = await _local.add(item);

    return localResult.fold(
      (l) => Left(l),
      (_) async {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remote.add(item);
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _local.markAsSynced(item.itemId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> remove(String itemId) async {
    final localResult = await _local.remove(itemId);

    return localResult.fold(
      (l) => Left(l),
      (_) async {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remote.remove(itemId);
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _local.markAsSynced(itemId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> restore(FreezerItemEntity item) async {
    final localResult = await _local.restore(item);

    return localResult.fold(
      (l) => Left(l),
      (_) async {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remote.restore(item);
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _local.markAsSynced(item.itemId);
            return const Right(null);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> update(FreezerItemEntity item) async {
    final localResult = await _local.update(item);

    return localResult.fold(
      (l) => Left(l),
      (_) async {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (!isOnline) return const Right(null);

        final remoteResult = await _remote.update(item);
        return remoteResult.fold(
          (_) => const Right(null),
          (_) async {
            await _local.markAsSynced(item.itemId);
            return const Right(null);
          },
        );
      },
    );
  }

  // read: tylko lokalny cache
  @override
  Future<Either<Failure, List<FreezerItemEntity>>> getAll() => _local.getAll();

  @override
  Future<Either<Failure, List<FreezerItemEntity>>> getUnsyncedChanges() =>
      _local.getUnsyncedChanges();

  @override
  Future<Either<Failure, void>> markAsSynced(String itemId) =>
      _local.markAsSynced(itemId);
}