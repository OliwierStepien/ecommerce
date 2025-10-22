import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/get_shopping_list.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/restore_to_shopping_list_usecase.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_state.dart';

class ShoppingListMealIngredientCubit
    extends Cubit<ShoppingListMealIngredientState> {
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
        super(const ShoppingListMealIngredientInitial()) {
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    emit(const ShoppingListMealIngredientLoading());
    final result = await _getUseCase.call(NoParams());
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load shopping list: $failure');
        emit(ShoppingListMealIngredientError(message: failure.toString()));
      },
      (shoppingListItems) {
        final List<Map<String, dynamic>> mappedItems = [];

        for (final item in shoppingListItems) {
          mappedItems.add(
              _createItemMap(item.ingredient, item.meal, item.portionCount));
        }

        emit(ShoppingListMealIngredientLoaded(items: mappedItems));
      },
    );
  }

  Future<void> addIngredient(
    IngredientEntity ingredient,
    MealEntity meal, {
    required int portionCount,
    bool suppressNotification = false,
  }) async {
    if (state is! ShoppingListMealIngredientLoaded) return;
    final currentState = state as ShoppingListMealIngredientLoaded;
    final previousItems = currentState.items;

    try {
      _suppressNotifications = suppressNotification;

      final updatedList = List<Map<String, dynamic>>.from(previousItems)
        ..add(_createItemMap(ingredient, meal, portionCount));

      emit(currentState.copyWith(items: updatedList));

      // Use case zwraca void, więc nie używamy result.fold
      await _addUseCase.call(
        AddToShoppingListParams(
          meal: meal,
          ingredient: ingredient,
          portionCount: portionCount,
        ),
      );

      await _syncStrategy.onDataChanged();
    } catch (e) {
      // W przypadku błędu przywróć poprzedni stan
      emit(currentState.copyWith(items: previousItems));
      debugPrint('❌ Failed to add ingredient: $e');
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
    if (state is! ShoppingListMealIngredientLoaded) return;
    final currentState = state as ShoppingListMealIngredientLoaded;
    final previousItems = currentState.items;

    try {
      _suppressNotifications = suppressNotification;

      final existingIngredientIndex = previousItems.indexWhere(
        (item) =>
            item['ingredientId'] == ingredient.ingredientId &&
            item['mealId'] == meal.mealId,
      );

      if (existingIngredientIndex != -1) {
        _lastRemovedItem = {
          'item': previousItems[existingIngredientIndex],
          'index': existingIngredientIndex,
        };

        final updatedList = List<Map<String, dynamic>>.from(previousItems)
          ..removeAt(existingIngredientIndex);

        emit(currentState.copyWith(items: updatedList));

        // Use case zwraca void, więc nie używamy result.fold
        await _removeUseCase.call(
          RemoveFromShoppingListParams(
            meal: meal,
            ingredient: ingredient,
          ),
        );

        await _syncStrategy.onDataChanged();
      }
    } catch (e) {
      // W przypadku błędu przywróć poprzedni stan
      emit(currentState.copyWith(items: previousItems));
      debugPrint('❌ Failed to remove ingredient: $e');
      rethrow;
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> updateIngredientPortion(
    IngredientEntity ingredient,
    MealEntity meal, {
    required int newPortionCount,
    bool suppressNotification = false,
  }) async {
    if (state is! ShoppingListMealIngredientLoaded) return;
    final currentState = state as ShoppingListMealIngredientLoaded;
    final previousItems = currentState.items;

    try {
      _suppressNotifications = suppressNotification;

      final existingIngredientIndex = previousItems.indexWhere(
        (item) =>
            item['ingredientId'] == ingredient.ingredientId &&
            item['mealId'] == meal.mealId,
      );

      if (existingIngredientIndex != -1) {
        // Usuń stary wpis
        try {
          await _removeUseCase.call(
            RemoveFromShoppingListParams(
              meal: meal,
              ingredient: ingredient,
            ),
          );
        } catch (e) {
          emit(currentState.copyWith(items: previousItems));
          debugPrint('❌ Failed to remove ingredient during update: $e');
          return;
        }

        // Dodaj z nową liczbą porcji
        try {
          await _addUseCase.call(
            AddToShoppingListParams(
              meal: meal,
              ingredient: ingredient,
              portionCount: newPortionCount,
            ),
          );
        } catch (e) {
          // Jeśli dodanie się nie udało, spróbuj przywrócić usunięty element
          try {
            await _addUseCase.call(
              AddToShoppingListParams(
                meal: meal,
                ingredient: ingredient,
                portionCount: previousItems[existingIngredientIndex]
                    ['portionCount'],
              ),
            );
          } catch (restoreError) {
            debugPrint(
                '❌ Failed to restore ingredient after update error: $restoreError');
          }
          emit(currentState.copyWith(items: previousItems));
          debugPrint('❌ Failed to add ingredient during update: $e');
          return;
        }

        // Zaktualizuj stan lokalny
        final updatedList = List<Map<String, dynamic>>.from(previousItems);
        updatedList[existingIngredientIndex] =
            _createItemMap(ingredient, meal, newPortionCount);

        emit(currentState.copyWith(items: updatedList));
        await _syncStrategy.onDataChanged();
      }
    } catch (e) {
      emit(currentState.copyWith(items: previousItems));
      debugPrint('❌ Failed to update ingredient portion: $e');
      rethrow;
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> restoreLastRemovedIngredient() async {
    if (_lastRemovedItem != null && !_lastRemovedItem!['item']['isCustom']) {
      if (state is! ShoppingListMealIngredientLoaded) return;

      final currentState = state as ShoppingListMealIngredientLoaded;
      final previousItems = currentState.items;

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

      try {
        _suppressNotifications = true;

        // Use case zwraca void, więc nie używamy result.fold
        await _restoreUseCase.call(
          RestoreToShoppingListParams(
            meal: meal,
            ingredient: ingredient,
            portionCount: portionCount,
          ),
        );

        final updatedList = List<Map<String, dynamic>>.from(previousItems)
          ..insert(index, item);
        emit(currentState.copyWith(items: updatedList));
        _lastRemovedItem = null;

        await _syncStrategy.onDataChanged();
      } catch (e) {
        emit(currentState.copyWith(items: previousItems));
        debugPrint('❌ Failed to restore ingredient: $e');
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
      'portionCount': portionCount,
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

  @override
  Future<void> close() {
    _syncStrategy.dispose();
    return super.close();
  }
}
