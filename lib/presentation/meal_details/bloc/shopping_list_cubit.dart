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

      // Szukamy składnika w aktualnym stanie
      final existingIngredientIndex = state.indexWhere(
        (item) => item['ingredient'] == ingredient && item['mealId'] == meal.mealId,
      );

      if (existingIngredientIndex != -1) {
        // Zapisujemy usunięty element i jego indeks
        _lastRemovedItem = {
          'item': state[existingIngredientIndex],
          'index': existingIngredientIndex,
        };
        updatedList = List.from(state)..removeAt(existingIngredientIndex);
      } else {
        // Dodajemy nowy składnik do listy
        updatedList = List.from(state)
          ..add({
            'ingredient': ingredient,
            'mealId': meal.mealId,
            'title': meal.title,
            'mealEntity': meal,
          });
      }

      // Emitujemy nowy stan
      emit(updatedList);

      // Wywołujemy metodę z repozytorium
      await sl<MealRepository>().addOrRemoveShoppingListIngredient(meal);
    } catch (e) {
      // W przypadku błędu przywracamy poprzedni stan
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

      // Emitujemy zaktualizowany stan
      emit(updatedList);
      _lastRemovedItem = null;
    }
  }

  bool get shouldShowNotification => !_suppressNotifications;
}