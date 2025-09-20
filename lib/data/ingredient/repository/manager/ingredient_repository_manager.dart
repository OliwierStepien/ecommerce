import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';

class IngredientRepositoryManager extends IngredientRepository {
  final IngredientRepository _localRepository;
  final IngredientRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  IngredientRepositoryManager({
    required IngredientRepository localRepository,
    required IngredientRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  /// 🔄 Pomocnicza metoda – ujednolica logikę pobierania danych
  Future<Either<Failure, List<IngredientEntity>>> _fetchData(
    Future<Either<Failure, List<IngredientEntity>>> Function() remoteCall,
    Future<Either<Failure, List<IngredientEntity>>> Function() localCall,
  ) async {
    final isOnline = await _networkInfo.checkInternetConnection();

    if (isOnline) {
      final result = await remoteCall();

      result.fold(
        (failure) => debugPrint('[IngredientRepo] Remote fetch failed: $failure'),
        (_) => debugPrint('[IngredientRepo] Remote fetch success'),
      );

      return result;
    } else {
      debugPrint('[IngredientRepo] Offline mode → using local cache');
      return await localCall();
    }
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() async {
    return _fetchData(
      () => _remoteRepository.getAllIngredients(),
      () => _localRepository.getAllIngredients(),
    );
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(
      String mealId) async {
    return _fetchData(
      () => _remoteRepository.getIngredientsForMeal(mealId),
      () => _localRepository.getIngredientsForMeal(mealId),
    );
  }
}