import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';

class ShoppingListMealIngredientSyncService implements SyncService {
  final ShoppingListMealIngredientRepository _firebaseRepo;
  final NetworkInfo _networkInfo;

  ShoppingListMealIngredientSyncService({
    required ShoppingListMealIngredientRepository firebaseRepo,
    required ShoppingListMealIngredientRepository hiveRepo,
    required NetworkInfo networkInfo,
  })  : _firebaseRepo = firebaseRepo,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> syncData() async {
    final isOnline = await _networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure());
    }

    // Pobierz bezpośrednio modele z Hive zamiast zgrupowanych danych
    final box = Hive.box<ShoppingListMealIngredientModel>('shoppingListMealIngredients');
    final unsyncedModels = box.values.where((model) => !model.isSynced).toList();

    // Najpierw usuń wszystkie oznaczone do usunięcia
    final modelsToDelete = unsyncedModels.where((model) => model.isDeleted);
    for (final model in modelsToDelete) {
      final result = await _firebaseRepo.removeMealIngredientFromShoppingList(
        MealMapper.toEntity(model.meal),
        IngredientMapper.toEntity(model.ingredient),
      );
      if (result.isLeft()) return Left((result as Left).value);
      
      await box.delete('${model.meal.mealId}_${model.ingredient.ingredientId}');
    }

    // Następnie dodaj/aktualizuj nowe składniki
    final modelsToAddOrUpdate = unsyncedModels.where((model) => !model.isDeleted);
    for (final model in modelsToAddOrUpdate) {
      // Najpierw usuń istniejący składnik (jeśli istnieje) aby uniknąć duplikatów
      final removeResult = await _firebaseRepo.removeMealIngredientFromShoppingList(
        MealMapper.toEntity(model.meal),
        IngredientMapper.toEntity(model.ingredient),
      );
      if (removeResult.isLeft()) return Left((removeResult as Left).value);

      // Następnie dodaj nową wersję
      final addResult = await _firebaseRepo.addMealIngredientToShoppingList(
        MealMapper.toEntity(model.meal),
        IngredientMapper.toEntity(model.ingredient),
        model.portionCount,
      );
      if (addResult.isLeft()) return Left((addResult as Left).value);

      // Oznacz jako zsynchronizowany
      await box.put(
        '${model.meal.mealId}_${model.ingredient.ingredientId}',
        ShoppingListMealIngredientModel(
          meal: model.meal,
          ingredient: model.ingredient,
          portionCount: model.portionCount,
          isSynced: true,
          isDeleted: false,
        ),
      );
    }

    return const Right(null);
  }
}