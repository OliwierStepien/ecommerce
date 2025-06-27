import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class ShoppingListCubit extends Cubit<List<Map<String, dynamic>>> {
  ShoppingListCubit() : super([]);

  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;

Future<void> addOrRemoveIngredient(
  IngredientEntity ingredient, 
  MealEntity meal, {
  bool suppressNotification = false,
  num? scaledAmount,
}) async {
  final List<Map<String, dynamic>> previousState = List.from(state);
  final List<Map<String, dynamic>> updatedList;
  
  try {
    _suppressNotifications = suppressNotification;

    final existingIngredientIndex = state.indexWhere(
      (item) => item['ingredientId'] == ingredient.ingredientId && 
               item['mealId'] == meal.mealId,
    );

    if (existingIngredientIndex != -1) {
      _lastRemovedItem = {
        'item': state[existingIngredientIndex],
        'index': existingIngredientIndex,
      };
      updatedList = List.from(state)..removeAt(existingIngredientIndex);
    } else {
      updatedList = List.from(state)
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
        });
    }

    emit(updatedList);
    await sl<MealRepository>().addOrRemoveShoppingListIngredient(meal);
  } catch (e) {
    emit(previousState);
    rethrow;
  } finally {
    _suppressNotifications = false;
  }
}

  void restoreLastRemovedIngredient() {
    if (_lastRemovedItem != null) {
      final Map<String, dynamic> item = _lastRemovedItem!['item'];
      final int index = _lastRemovedItem!['index'];

      final List<Map<String, dynamic>> updatedList = List.from(state);
      updatedList.insert(index, item);

      emit(updatedList);
      _lastRemovedItem = null;
    }
  }

  bool get shouldShowNotification => !_suppressNotifications;

void addCustomIngredient(String ingredientName, {String category = 'Inne'}) {
  final List<Map<String, dynamic>> updatedList = List.from(state)
    ..add({
      'ingredientId': 'custom_${DateTime.now().millisecondsSinceEpoch}',
      'ingredientName': ingredientName,
      'amountPerPortion': null,
      'unit': '',
      'ingredientCategory': category,
      'mealId': null,
      'title': '',
      'mealEntity': null,
    });

  emit(updatedList);
}

  void removeCustomIngredient(String ingredientId) {
    final index = state.indexWhere((item) =>
        item['ingredientId'] == ingredientId && item['mealId'] == null);
    if (index != -1) {
      _lastRemovedItem = {
        'item': state[index],
        'index': index,
      };

      final List<Map<String, dynamic>> updatedList = List.from(state)..removeAt(index);
      emit(updatedList);
    }
  }

  void updateIngredientCategory(String ingredientId, String newCategory) {
    final index = state.indexWhere((item) => item['ingredientId'] == ingredientId);
    if (index != -1) {
      final updatedItem = Map<String, dynamic>.from(state[index])
        ..['ingredientCategory'] = newCategory;

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..[index] = updatedItem;

      emit(updatedList);
    }
  }
}