import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class MealRepositoryManager extends MealRepository {
  final MealRepository _localRepository;
  final MealRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  MealRepositoryManager({
    required MealRepository localRepository,
    required MealRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  /// 🔄 Pomocnicza metoda – pobiera wszystkie posiłki z remote (Firebase)
  /// i nadpisuje nimi lokalną bazę (Hive).
  ///
  /// Dzięki temu lokalne dane zawsze odzwierciedlają stan serwera,
  /// co pozwala korzystać z aplikacji również w trybie offline.
  Future<void> _syncRemoteToLocal() async {
    final remoteMealsResult = await _remoteRepository.getMeals();

    await remoteMealsResult.fold(
      // Jeśli nie udało się pobrać danych z Firebase → tylko logujemy błąd,
      // lokalne dane pozostają niezmienione.
      (failure) async =>
          debugPrint('[MealRepo] Failed to sync meals: $failure'),

      // Jeśli pobraliśmy posiłki poprawnie → zapisujemy je w Hive
      (meals) async {
        debugPrint('[MealRepo] Syncing ${meals.length} meals to Hive');
        await _localRepository.saveMeals(meals);
      },
    );
  }

  /// 🔄 Pomocnicza metoda – ujednolica logikę pobierania danych.
  ///
  /// 1. Jeśli użytkownik jest ONLINE:
  ///    - wywołujemy podane `remoteCall` (np. `getMealsByTitle`)
  ///    - jeśli się uda → dodatkowo synchronizujemy wszystkie posiłki
  ///      z Firebase do Hive (za pomocą [_syncRemoteToLocal])
  ///    - zwracamy wynik `remoteCall`
  ///
  /// 2. Jeśli użytkownik jest OFFLINE:
  ///    - wywołujemy podane `localCall` (np. `getMealsByTitle` z Hive)
  ///    - zwracamy wynik z lokalnej bazy
  ///
  /// Dzięki temu cała logika *sprawdź internet → pobierz → zsynchronizuj*
  /// znajduje się w jednym miejscu i nie powtarza się w każdej metodzie repo.
  Future<Either<Failure, List<MealEntity>>> _fetchAndSync(
    Future<Either<Failure, List<MealEntity>>> Function() remoteCall,
    Future<Either<Failure, List<MealEntity>>> Function() localCall,
  ) async {
    final isOnline = await _networkInfo.checkInternetConnection();

    if (isOnline) {
      final result = await remoteCall();

      result.fold(
        // Jeśli zdalne pobranie się nie uda → tylko logujemy błąd,
        // aplikacja wciąż dostaje odpowiedź z remote (z błędem).
        (failure) => debugPrint('[MealRepo] Remote fetch failed: $failure'),

        // Jeśli się udało → zsynchronizuj wszystkie posiłki do Hive
        (_) async => await _syncRemoteToLocal(),
      );

      return result;
    } else {
      // Jeśli offline → korzystamy tylko z lokalnych danych
      return await localCall();
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMeals() async {
    return _fetchAndSync(
      () => _remoteRepository.getMeals(),
      () => _localRepository.getMeals(),
    );
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByCategoryId(
      String categoryId) async {
    return _fetchAndSync(
      () => _remoteRepository.getMealsByCategoryId(categoryId),
      () => _localRepository.getMealsByCategoryId(categoryId),
    );
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByTitle(
      String title) async {
    return _fetchAndSync(
      () => _remoteRepository.getMealsByTitle(title),
      () => _localRepository.getMealsByTitle(title),
    );
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByCategoryId(
      String categoryId) async {
    return _fetchAndSync(
      () => _remoteRepository.getVegetarianMealsByCategoryId(categoryId),
      () => _localRepository.getVegetarianMealsByCategoryId(categoryId),
    );
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getVegetarianMealsByTitle(
      String title) async {
    return _fetchAndSync(
      () => _remoteRepository.getVegetarianMealsByTitle(title),
      () => _localRepository.getVegetarianMealsByTitle(title),
    );
  }

  @override
  Future<Either<Failure, List<MealEntity>>> isMealVegetarian(
      bool isVegetarian) async {
    return _fetchAndSync(
      () => _remoteRepository.isMealVegetarian(isVegetarian),
      () => _localRepository.isMealVegetarian(isVegetarian),
    );
  }

  @override
  Future<Either<Failure, List<MealEntity>>> saveMeals(
      List<MealEntity> meals) async {
    // Zapis tylko lokalnie (Hive), ponieważ Firebase nie obsługuje zapisu
    return await _localRepository.saveMeals(meals);
  }
}
