import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';
import 'package:mealapp/service_locator.dart';

class ShoppingListCubit extends Cubit<List<Map<String, dynamic>>> {
  ShoppingListCubit() : super([]);

  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;

  Future<void> addIngredient(
    IngredientEntity ingredient,
    MealEntity meal, {
    required int portionCount,
    bool suppressNotification = false,
  }) async {
    final List<Map<String, dynamic>> previousState = List<Map<String, dynamic>>.from(state);

    try {
      _suppressNotifications = suppressNotification;

      // Oblicz skalowaną ilość składnika
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
        });

      emit(updatedList);
      await sl<ShoppingListMealIngredientRepository>()
          .addMealIngredientToShoppingList(meal, ingredient, portionCount);
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
    final List<Map<String, dynamic>> previousState = List<Map<String, dynamic>>.from(state);

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

        final updatedList = List<Map<String, dynamic>>.from(state)..removeAt(existingIngredientIndex);
        emit(updatedList);
        await sl<ShoppingListMealIngredientRepository>().removeMealIngredientFromShoppingList(meal, ingredient);
      }
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

      final updatedList = List<Map<String, dynamic>>.from(state);
      updatedList.insert(index, item);

      emit(updatedList);
      _lastRemovedItem = null;
    }
  }

  bool get shouldShowNotification => !_suppressNotifications;

  void addCustomIngredient(String ingredientName, {String category = 'Inne'}) {
    final updatedList = List<Map<String, dynamic>>.from(state)
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

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..removeAt(index);
      emit(updatedList);
    }
  }

  void updateIngredientCategory(String ingredientId, String newCategory) {
    final index =
        state.indexWhere((item) => item['ingredientId'] == ingredientId);
    if (index != -1) {
      final updatedItem = Map<String, dynamic>.from(state[index])
        ..['ingredientCategory'] = newCategory;

      final updatedList = List<Map<String, dynamic>>.from(state)
        ..[index] = updatedItem;

      emit(updatedList);
    }
  }
}