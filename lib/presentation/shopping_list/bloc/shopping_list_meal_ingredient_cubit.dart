import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/restore_to_shopping_list_usecase.dart';
import 'package:mealapp/core/network/sync_controller.dart';
import 'package:mealapp/service_locator.dart';


class ShoppingListMealIngredientCubit
    extends Cubit<List<Map<String, dynamic>>> {
  ShoppingListMealIngredientCubit() : super([]);

  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;
  Timer? _syncDebounceTimer;

  Future<void> addIngredient(
    IngredientEntity ingredient,
    MealEntity meal, {
    required int portionCount,
    bool suppressNotification = false,
  }) async {
    final previousState = List<Map<String, dynamic>>.from(state);

    try {
      _suppressNotifications = suppressNotification;

      final scaledAmount = ingredient.amountPerPortion != null
          ? ingredient.amountPerPortion! * portionCount
          : null;

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..add({
          'ingredientId': ingredient.ingredientId,
          'ingredientName': ingredient.ingredientName,
          'amountPerPortion': ingredient.amountPerPortion,
          'scaledAmount': scaledAmount,
          'unit': ingredient.unit,
          'ingredientCategory': ingredient.ingredientCategory,
          'mealId': meal.mealId,
          'title': meal.title,
          'mealEntity': meal,
          'portionCount': portionCount,
          'isCustom': false,
        });

      emit(updatedList);
      await sl<AddToShoppingListUseCase>().call(params: {
        'meal': meal,
        'ingredient': ingredient,
        'portionCount': portionCount,
      });

      _scheduleSync();
    } catch (e) {
      emit(previousState);
      rethrow;
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> removeIngredient(
    IngredientEntity ingredient,
    MealEntity meal, {
    bool suppressNotification = false,
  }) async {
    final previousState = List<Map<String, dynamic>>.from(state);

    try {
      _suppressNotifications = suppressNotification;

      final existingIngredientIndex = state.indexWhere(
        (item) =>
            item['ingredientId'] == ingredient.ingredientId &&
            item['mealId'] == meal.mealId,
      );

      if (existingIngredientIndex != -1) {
        _lastRemovedItem = {
          'item': state[existingIngredientIndex],
          'index': existingIngredientIndex,
        };

        final updatedList = List<Map<String, dynamic>>.from(state)
          ..removeAt(existingIngredientIndex);
        emit(updatedList);
        await sl<RemoveFromShoppingListUseCase>().call(params: {
          'meal': meal,
          'ingredient': ingredient,
        });

        _scheduleSync();
      }
    } catch (e) {
      emit(previousState);
      rethrow;
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> restoreLastRemovedIngredient() async {
    if (_lastRemovedItem != null && !_lastRemovedItem!['item']['isCustom']) {
      final item = _lastRemovedItem!['item'];
      final index = _lastRemovedItem!['index'];
      final meal = item['mealEntity'] as MealEntity;
      final ingredient = IngredientEntity(
        ingredientId: item['ingredientId'],
        ingredientName: item['ingredientName'],
        amountPerPortion: item['amountPerPortion'],
        unit: item['unit'],
        ingredientCategory: item['ingredientCategory'],
        mealId: item['mealId'],
      );
      final portionCount = item['portionCount'] as int;

      final previousState = List<Map<String, dynamic>>.from(state);

      try {
        _suppressNotifications = true;

        await sl<RestoreToShoppingListUseCase>().call(params: {
          'meal': meal,
          'ingredient': ingredient,
          'portionCount': portionCount,
        });

        final updatedList = List<Map<String, dynamic>>.from(state)
          ..insert(index, item);
        emit(updatedList);
        _lastRemovedItem = null;

        _scheduleSync();
      } catch (e) {
        emit(previousState);
        rethrow;
      } finally {
        _suppressNotifications = false;
      }
    }
  }

  bool get shouldShowNotification => !_suppressNotifications;

void _scheduleSync() {
  print('[Sync] Oczekuję na synchronizację...');
  _syncDebounceTimer?.cancel();
  _syncDebounceTimer = Timer(const Duration(seconds: 2), () async {
    print('[Sync] Wywołuję syncAll...');
    await sl<SyncController>().syncAll();
    print('[Sync] Synchronizacja zakończona.');
  });
}

  @override
  Future<void> close() {
    _syncDebounceTimer?.cancel();
    return super.close();
  }
}