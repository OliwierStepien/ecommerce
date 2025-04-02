import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class ShoppingListCubit extends Cubit<List<Map<String, dynamic>>> {
  ShoppingListCubit() : super([]);

  Map<String, dynamic>? _lastRemovedItem;
  bool _suppressNotifications = false;

  Future<void> addOrRemoveIngredient(
    String ingredient, 
    MealEntity meal, {
    bool suppressNotification = false,
  }) async {
    final List<Map<String, dynamic>> previousState = List.from(state);
    final List<Map<String, dynamic>> updatedList;
    
    try {
      _suppressNotifications = suppressNotification;


      final existingIngredientIndex = state.indexWhere(
        (item) => item['ingredient'] == ingredient && item['mealId'] == meal.mealId,
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
            'ingredient': ingredient,
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
}