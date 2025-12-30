import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';
import 'package:mealapp/domain/grocery/repository/grocery_repository.dart';

class GroceryRepositoryManager extends GroceryRepository {
  final GroceryRepository _localRepository;
  final GroceryRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  GroceryRepositoryManager({
    required GroceryRepository localRepository,
    required GroceryRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  Future<void> _syncRemoteToLocal() async {
    final remoteResult = await _remoteRepository.getGroceries();

    await remoteResult.fold(
      (failure) async =>
          debugPrint('[GroceryRepo] Failed to sync groceries: $failure'),
      (groceries) async {
        debugPrint('[GroceryRepo] Syncing ${groceries.length} groceries to Hive');
        await _localRepository.saveGroceries(groceries);
      },
    );
  }

  Future<Either<Failure, List<GroceryEntity>>> _fetchAndSync(
    Future<Either<Failure, List<GroceryEntity>>> Function() remoteCall,
    Future<Either<Failure, List<GroceryEntity>>> Function() localCall,
  ) async {
    final isOnline = await _networkInfo.checkInternetConnection();
    debugPrint('[GroceryRepo] Connection status: ${isOnline ? 'ONLINE' : 'OFFLINE'}');

    if (isOnline) {
      final result = await remoteCall();

      result.fold(
        (failure) => debugPrint('[GroceryRepo] Remote fetch failed: $failure'),
        (_) async => await _syncRemoteToLocal(),
      );

      return result;
    } else {
      return await localCall();
    }
  }

  @override
  Future<Either<Failure, List<GroceryEntity>>> getGroceries() async {
    return _fetchAndSync(
      () => _remoteRepository.getGroceries(),
      () => _localRepository.getGroceries(),
    );
  }

  @override
  Future<Either<Failure, List<GroceryEntity>>> saveGroceries(
    List<GroceryEntity> groceries,
  ) async {
    // analogicznie jak Categories: zapis lokalny
    return await _localRepository.saveGroceries(groceries);
  }
}