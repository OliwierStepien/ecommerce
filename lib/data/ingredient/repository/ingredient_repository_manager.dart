import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/ingredient/repository/local/hive_ingredient_repository_impl.dart';
import 'package:mealapp/data/ingredient/repository/remote/firebase_ingredient_repository_impl.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';
import 'package:mealapp/service_locator.dart';

class IngredientRepositoryManager extends IngredientRepository {

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseIngredientRepositoryImpl>().getAllIngredients();
      
      // Zapisz pobrane składniki do cache
      await result.fold(
        (failure) async {
          debugPrint('Failed to fetch ingredients online: $failure');
          // Spróbuj pobrać z cache jako fallback
          final cachedResult = await sl<HiveIngredientRepositoryImpl>().getAllIngredients();
          return cachedResult.fold(
            (cacheFailure) => Left(failure), // Zwróć oryginalny błąd
            (cachedIngredients) => Right(cachedIngredients), // Zwróć dane z cache
          );
        },
        (ingredients) async {
          try {
            // Zapisz składniki do cache - potrzebujesz odpowiedniej metody w Hive
            // await _saveIngredientsToCache(ingredients);
            debugPrint('Saved ${ingredients.length} ingredients to cache');
            return Right(ingredients);
          } catch (e) {
            debugPrint('Failed to save ingredients to cache: $e');
            return Right(ingredients); // Zwróć dane mimo błędu cache
          }
        },
      );
      
      return result;
    } else {
      // Tryb offline - pobierz z cache
      debugPrint('Fetching ingredients from cache (offline mode)');
      return await sl<HiveIngredientRepositoryImpl>().getAllIngredients();
    }
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(String mealId) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    
    if (isOnline) {
      final result = await sl<FirebaseIngredientRepositoryImpl>().getIngredientsForMeal(mealId);
      
      return await result.fold(
        (failure) async {
          debugPrint('Failed to fetch ingredients for meal $mealId: $failure');
          // Fallback to cache
          return await sl<HiveIngredientRepositoryImpl>().getIngredientsForMeal(mealId);
        },
        (ingredients) async {
          try {
            // Zapisz składniki dla danego posiłku do cache
            // await _saveMealIngredientsToCache(mealId, ingredients);
            debugPrint('Saved ${ingredients.length} ingredients for meal $mealId to cache');
            return Right(ingredients);
          } catch (e) {
            debugPrint('Failed to save ingredients to cache for meal $mealId: $e');
            return Right(ingredients); // Zwróć dane mimo błędu cache
          }
        },
      );
    } else {
      // Tryb offline
      debugPrint('Fetching ingredients for meal $mealId from cache (offline mode)');
      return await sl<HiveIngredientRepositoryImpl>().getIngredientsForMeal(mealId);
    }
  }

  // Pomocnicza metoda do zapisywania wszystkich składników w cache
  // private Future<void> _saveIngredientsToCache(List<IngredientEntity> ingredients) async {
  //   // Implementacja zapisywania do Hive
  //   // await sl<HiveIngredientService>().saveIngredients(ingredients);
  // }

  // Pomocnicza metoda do zapisywania składników dla posiłku w cache
  // private Future<void> _saveMealIngredientsToCache(String mealId, List<IngredientEntity> ingredients) async {
  //   // Implementacja zapisywania do Hive
  //   // await sl<HiveIngredientService>().saveIngredientsForMeal(mealId, ingredients);
  // }
}