import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/get_shopping_list.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/restore_to_shopping_list_usecase.dart';

class ShoppingListMealIngredientCubit extends Cubit<List<Map<String, dynamic>>> {
  final AddToShoppingListUseCase _addUseCase;
  final RemoveFromShoppingListUseCase _removeUseCase;
  final RestoreToShoppingListUseCase _restoreUseCase;
  final GetShoppingListUseCase _getUseCase;
  final SyncStrategy _syncStrategy;

  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;

  ShoppingListMealIngredientCubit({
    required AddToShoppingListUseCase addUseCase,
    required RemoveFromShoppingListUseCase removeUseCase,
    required RestoreToShoppingListUseCase restoreUseCase,
    required GetShoppingListUseCase getUseCase,
    required SyncStrategy syncStrategy,
  })  : _addUseCase = addUseCase,
        _removeUseCase = removeUseCase,
        _restoreUseCase = restoreUseCase,
        _getUseCase = getUseCase,
        _syncStrategy = syncStrategy,
        super([]) {
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final result = await _getUseCase.call();
    result.fold(
      (failure) => debugPrint('❌ Failed to load shopping list: $failure'),
      (shoppingListItems) {
        final List<Map<String, dynamic>> mappedItems = [];

        for (final item in shoppingListItems) {
          mappedItems.add(_createItemMap(
            item.ingredient, 
            item.meal, 
            item.portionCount
          ));
        }

        emit(mappedItems);
      },
    );
  }

  Future<void> addIngredient(
    IngredientEntity ingredient,
    MealEntity meal, {
    required int portionCount,
    bool suppressNotification = false,
  }) async {
    final previousState = List<Map<String, dynamic>>.from(state);

    try {
      _suppressNotifications = suppressNotification;

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..add(_createItemMap(ingredient, meal, portionCount));

      emit(updatedList);
      await _addUseCase.call(params: {
        'meal': meal,
        'ingredient': ingredient,
        'portionCount': portionCount,
      });

      await _syncStrategy.onDataChanged();
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
        await _removeUseCase.call(params: {
          'meal': meal,
          'ingredient': ingredient,
        });

        await _syncStrategy.onDataChanged();
      }
    } catch (e) {
      emit(previousState);
      rethrow;
    } finally {
      _suppressNotifications = false;
    }
  }

  // ✅ DODANA METODA: Aktualizacja liczby porcji
  Future<void> updateIngredientPortion(
    IngredientEntity ingredient,
    MealEntity meal, {
    required int newPortionCount,
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
        // Usuń stary wpis
        await _removeUseCase.call(params: {
          'meal': meal,
          'ingredient': ingredient,
        });

        // Dodaj z nową liczbą porcji
        await _addUseCase.call(params: {
          'meal': meal,
          'ingredient': ingredient,
          'portionCount': newPortionCount,
        });

        // Zaktualizuj stan lokalny
        final updatedList = List<Map<String, dynamic>>.from(state);
        updatedList[existingIngredientIndex] = _createItemMap(
          ingredient, 
          meal, 
          newPortionCount
        );

        emit(updatedList);
        await _syncStrategy.onDataChanged();
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

        await _restoreUseCase.call(params: {
          'meal': meal,
          'ingredient': ingredient,
          'portionCount': portionCount,
        });

        final updatedList = List<Map<String, dynamic>>.from(state)
          ..insert(index, item);

        emit(updatedList);
        _lastRemovedItem = null;
        await _syncStrategy.onDataChanged();
      } catch (e) {
        emit(previousState);
        rethrow;
      } finally {
        _suppressNotifications = false;
      }
    }
  }

  Map<String, dynamic> _createItemMap(
    IngredientEntity ingredient,
    MealEntity meal,
    int portionCount,
  ) {
    return {
      'ingredientId': ingredient.ingredientId,
      'ingredientName': ingredient.ingredientName,
      'amountPerPortion': ingredient.amountPerPortion,
      'scaledAmount': _calculateScaledAmount(ingredient, portionCount),
      'unit': ingredient.unit,
      'ingredientCategory': ingredient.ingredientCategory,
      'mealId': meal.mealId,
      'title': meal.title,
      'mealEntity': meal,
      'portionCount': portionCount, // ✅ ZAPISUJEMY portionCount
      'isCustom': false,
    };
  }

  double? _calculateScaledAmount(
      IngredientEntity ingredient, int portionCount) {
    return ingredient.amountPerPortion != null
        ? (ingredient.amountPerPortion! * portionCount).toDouble()
        : null;
  }

  bool get shouldShowNotification => !_suppressNotifications;
}