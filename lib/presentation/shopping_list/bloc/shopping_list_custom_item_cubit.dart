import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';

class ShoppingListCustomItemCubit extends Cubit<List<Map<String, dynamic>>> {
  ShoppingListCustomItemCubit() : super([]);

  Map<String, dynamic>? _lastRemovedItem;

  void addCustomIngredient(ShoppingListCustomItemEntity ingredient) {
    final updatedList = List<Map<String, dynamic>>.from(state)
      ..add({
        'ingredientId': ingredient.customItemId,
        'ingredientName': ingredient.customItemName,
        'ingredientCategory': ingredient.customItemCategory,
        'mealId': null,
        'title': '',
        'mealEntity': null,
        'amountPerPortion': null,
        'unit': '',
        'isCustom': true,
      });
    emit(updatedList);
  }

  void removeCustomIngredient(String ingredientId) {
    final index = state.indexWhere(
        (item) => item['ingredientId'] == ingredientId && item['isCustom']);
    if (index != -1) {
      _lastRemovedItem = {
        'item': state[index],
        'index': index,
      };

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..removeAt(index);
      emit(updatedList);
    }
  }

  void restoreLastRemovedIngredient() {
    if (_lastRemovedItem != null && _lastRemovedItem!['item']['isCustom']) {
      final item = _lastRemovedItem!['item'];
      final index = _lastRemovedItem!['index'];

      final updatedList = List<Map<String, dynamic>>.from(state);
      updatedList.insert(index, item);

      emit(updatedList);
      _lastRemovedItem = null;
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
}