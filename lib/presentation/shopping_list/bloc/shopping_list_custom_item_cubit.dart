import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/add_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/remove_custom_item_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/restore_custom_item_to_shopping_list_use_case.dart';

class ShoppingListCustomItemCubit extends Cubit<List<Map<String, dynamic>>> {
  final AddCustomItemToShoppingListUseCase _addUseCase;
  final RemoveCustomItemFromShoppingListUseCase _removeUseCase;
  final RestoreCustomItemToShoppingListUseCase _restoreUseCase;
  final SyncStrategy _syncStrategy;

  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;

  ShoppingListCustomItemCubit({
    required AddCustomItemToShoppingListUseCase addUseCase,
    required RemoveCustomItemFromShoppingListUseCase removeUseCase,
    required RestoreCustomItemToShoppingListUseCase restoreUseCase,
    required SyncStrategy syncStrategy,
  })  : _addUseCase = addUseCase,
        _removeUseCase = removeUseCase,
        _restoreUseCase = restoreUseCase,
        _syncStrategy = syncStrategy,
        super([]);

  Future<void> addCustomIngredient(
    ShoppingListCustomItemEntity ingredient, {
    bool suppressNotification = false,
  }) async {
    final previousState = List<Map<String, dynamic>>.from(state);

    try {
      _suppressNotifications = suppressNotification;

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..add(_createItemMap(ingredient));
      emit(updatedList);

      final result = await _addUseCase.call(params: ingredient);
      result.fold((_) => emit(previousState), (_) => null);

      await _syncStrategy.onDataChanged();
    } catch (e) {
      emit(previousState);
      rethrow;
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> removeCustomIngredient(
    String ingredientId, {
    bool suppressNotification = false,
  }) async {
    final previousState = List<Map<String, dynamic>>.from(state);

    try {
      _suppressNotifications = suppressNotification;

      final index = state.indexWhere(
        (item) => item['ingredientId'] == ingredientId && item['isCustom'],
      );

      if (index != -1) {
        _lastRemovedItem = {
          'item': state[index],
          'index': index,
        };

        final updatedList = List<Map<String, dynamic>>.from(state)
          ..removeAt(index);
        emit(updatedList);

        final result = await _removeUseCase.call(params: ingredientId);
        result.fold((_) => emit(previousState), (_) => null);

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
    if (_lastRemovedItem != null && _lastRemovedItem!['item']['isCustom']) {
      final item = _lastRemovedItem!['item'];
      final index = _lastRemovedItem!['index'];

      final customItem = ShoppingListCustomItemEntity(
        customItemId: item['ingredientId'],
        customItemName: item['ingredientName'],
        customItemCategory: item['ingredientCategory'],
      );

      final previousState = List<Map<String, dynamic>>.from(state);

      try {
        _suppressNotifications = true;

        final result =
            await _restoreUseCase.call(params: customItem);
        result.fold((_) => emit(previousState), (_) {
          final updatedList = List<Map<String, dynamic>>.from(state)
            ..insert(index, item);
          emit(updatedList);
          _lastRemovedItem = null;
        });

        await _syncStrategy.onDataChanged();
      } catch (e) {
        emit(previousState);
        rethrow;
      } finally {
        _suppressNotifications = false;
      }
    }
  }

  void updateIngredientCategory(String ingredientId, String newCategory) {
    final index = state.indexWhere(
        (item) => item['ingredientId'] == ingredientId && item['isCustom']);
    if (index != -1) {
      final updatedItem = Map<String, dynamic>.from(state[index])
        ..['ingredientCategory'] = newCategory;

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..[index] = updatedItem;

      emit(updatedList);
    }
  }

  Map<String, dynamic> _createItemMap(
      ShoppingListCustomItemEntity ingredient) {
    return {
      'ingredientId': ingredient.customItemId,
      'ingredientName': ingredient.customItemName,
      'ingredientCategory': ingredient.customItemCategory,
      'mealId': null,
      'title': '',
      'mealEntity': null,
      'amountPerPortion': null,
      'unit': '',
      'isCustom': true,
    };
  }

  bool get shouldShowNotification => !_suppressNotifications;

  @override
  Future<void> close() {
    _syncStrategy.dispose();
    return super.close();
  }
}