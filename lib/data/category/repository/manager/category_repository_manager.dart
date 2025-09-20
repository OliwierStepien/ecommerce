import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';

class CategoryRepositoryManager extends CategoryRepository {
  final CategoryRepository _localRepository;
  final CategoryRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  CategoryRepositoryManager({
    required CategoryRepository localRepository,
    required CategoryRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  /// 🔄 Pomocnicza metoda – pobiera wszystkie kategorie z remote (Firebase)
  /// i nadpisuje nimi lokalną bazę (Hive).
  Future<void> _syncRemoteToLocal() async {
    final remoteCategoriesResult = await _remoteRepository.getCategories();

    await remoteCategoriesResult.fold(
      (failure) async =>
          debugPrint('[CategoryRepo] Failed to sync categories: $failure'),
      (categories) async {
        debugPrint('[CategoryRepo] Syncing ${categories.length} categories to Hive');
        await _localRepository.saveCategories(categories);
      },
    );
  }

  /// 🔄 Pomocnicza metoda – ujednolica logikę pobierania danych.
  Future<Either<Failure, List<CategoryEntity>>> _fetchAndSync(
    Future<Either<Failure, List<CategoryEntity>>> Function() remoteCall,
    Future<Either<Failure, List<CategoryEntity>>> Function() localCall,
  ) async {
    final isOnline = await _networkInfo.checkInternetConnection();
    debugPrint(
        '[CategoryRepo] Connection status: ${isOnline ? 'ONLINE' : 'OFFLINE'}');

    if (isOnline) {
      final result = await remoteCall();

      result.fold(
        (failure) => debugPrint('[CategoryRepo] Remote fetch failed: $failure'),
        (_) async => await _syncRemoteToLocal(),
      );

      return result;
    } else {
      return await localCall();
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    return _fetchAndSync(
      () => _remoteRepository.getCategories(),
      () => _localRepository.getCategories(),
    );
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> saveCategories(
      List<CategoryEntity> categories) async {
    // zapisujemy tylko lokalnie, Firebase nie obsługuje zapisu kategorii
    return await _localRepository.saveCategories(categories);
  }
}