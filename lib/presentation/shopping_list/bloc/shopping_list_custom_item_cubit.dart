import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/add_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/get_shopping_list_custom_item.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/remove_custom_item_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/restore_custom_item_to_shopping_list_use_case.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/update_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_state.dart';

class ShoppingListCustomItemCubit extends Cubit<ShoppingListCustomItemState> {
  final AddCustomItemToShoppingListUseCase _addUseCase;
  final RemoveCustomItemFromShoppingListUseCase _removeUseCase;
  final RestoreCustomItemToShoppingListUseCase _restoreUseCase;
  final GetShoppingListCustomItemUseCase _getUseCase;
  final SyncStrategy _syncStrategy;
  final UpdateCustomItemToShoppingListUseCase _updateUseCase;

  /// 📦 Ostatnio usunięty element + jego oryginalna pozycja
  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;

  ShoppingListCustomItemCubit({
    required AddCustomItemToShoppingListUseCase addUseCase,
    required RemoveCustomItemFromShoppingListUseCase removeUseCase,
    required RestoreCustomItemToShoppingListUseCase restoreUseCase,
    required GetShoppingListCustomItemUseCase getUseCase,
    required UpdateCustomItemToShoppingListUseCase updateUseCase,
    required SyncStrategy syncStrategy,
  })  : _addUseCase = addUseCase,
        _removeUseCase = removeUseCase,
        _restoreUseCase = restoreUseCase,
        _getUseCase = getUseCase,
        _updateUseCase = updateUseCase,
        _syncStrategy = syncStrategy,
        super(const ShoppingListCustomItemInitial()) {
    _loadCustomItems();
  }

  Future<void> _loadCustomItems() async {
    emit(const ShoppingListCustomItemLoading());
    final result = await _getUseCase.call(NoParams());
    result.fold(
      (failure) =>
          emit(ShoppingListCustomItemError(message: failure.toString())),
      (customItems) => emit(ShoppingListCustomItemLoaded(items: customItems)),
    );
  }

  /// ✅ PUBLIC: użyj po bulk clear (albo ręcznie kiedy chcesz odświeżyć)
  Future<void> reload() async => _loadCustomItems();

  /// ✅ PUBLIC: natychmiast czyści widok (UI) bez czekania na IO
  void clearView() {
    emit(const ShoppingListCustomItemLoaded(items: []));
    _lastRemovedItem = null;
  }

  Future<void> addCustomIngredient(
    ShoppingListCustomItemEntity ingredient, {
    bool suppressNotification = false,
  }) async {
    if (state is! ShoppingListCustomItemLoaded) return;
    final currentState = state as ShoppingListCustomItemLoaded;
    final previousItems = currentState.items;

    try {
      _suppressNotifications = suppressNotification;

      final updatedList = List<ShoppingListCustomItemEntity>.from(previousItems)
        ..add(ingredient);

      emit(currentState.copyWith(items: updatedList));

      final result = await _addUseCase.call(ingredient);
      result.fold(
        (_) => emit(currentState.copyWith(items: previousItems)),
        (_) {},
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> removeCustomIngredient(
    String ingredientId, {
    bool suppressNotification = false,
  }) async {
    if (state is! ShoppingListCustomItemLoaded) return;
    final currentState = state as ShoppingListCustomItemLoaded;
    final previousItems = currentState.items;

    try {
      _suppressNotifications = suppressNotification;

      final index =
          previousItems.indexWhere((item) => item.customItemId == ingredientId);

      if (index != -1) {
        _lastRemovedItem = {
          'item': previousItems[index],
          'index': index,
        };

        final updatedList =
            List<ShoppingListCustomItemEntity>.from(previousItems)
              ..removeAt(index);

        emit(currentState.copyWith(items: updatedList));

        final result = await _removeUseCase.call(ingredientId);
        result.fold(
          (_) => emit(currentState.copyWith(items: previousItems)),
          (_) {},
        );

        await _syncStrategy.onDataChanged();
      }
    } finally {
      _suppressNotifications = false;
    }
  }

  /// ♻️ Przywraca ostatnio usunięty składnik niestandardowy
  ///     na jego oryginalne miejsce w liście.
  Future<void> restoreLastRemovedIngredient() async {
    if (_lastRemovedItem == null) return;
    if (state is! ShoppingListCustomItemLoaded) return;

    final currentState = state as ShoppingListCustomItemLoaded;
    final previousItems = currentState.items;

    final item = _lastRemovedItem!['item'] as ShoppingListCustomItemEntity;
    final index = _lastRemovedItem!['index'] as int;

    try {
      _suppressNotifications = true;

      final result = await _restoreUseCase.call(item);
      result.fold(
        (_) => emit(currentState.copyWith(items: previousItems)),
        (_) {
          // lista mogła się skrócić od czasu usunięcia — nie wychodź poza zakres
          final insertIndex =
              index > previousItems.length ? previousItems.length : index;
          final updatedList =
              List<ShoppingListCustomItemEntity>.from(previousItems)
                ..insert(insertIndex, item);
          emit(currentState.copyWith(items: updatedList));
          _lastRemovedItem = null;
        },
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }

  bool get shouldShowNotification => !_suppressNotifications;

  Future<void> updateCustomIngredient(
    ShoppingListCustomItemEntity updated, {
    bool suppressNotification = false,
  }) async {
    if (state is! ShoppingListCustomItemLoaded) return;
    final currentState = state as ShoppingListCustomItemLoaded;
    final previousItems = currentState.items;

    try {
      _suppressNotifications = suppressNotification;

      final idx = previousItems
          .indexWhere((x) => x.customItemId == updated.customItemId);
      if (idx == -1) return;

      final newList = List<ShoppingListCustomItemEntity>.from(previousItems);
      newList[idx] = updated;

      emit(currentState.copyWith(items: newList));

      final result = await _updateUseCase.call(updated);
      result.fold(
        (_) => emit(currentState.copyWith(items: previousItems)),
        (_) {},
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }
}