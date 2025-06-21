import 'package:flutter/material.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/usecase/favourite/add_or_remove_favorite_meal.dart';
import 'package:mealapp/domain/meal/usecase/favourite/get_favorites_meal.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/service_locator.dart';

class FavoriteMealsCubit extends Cubit<MealsDisplayState> {
  FavoriteMealsCubit() : super(MealsInitialState()) {
    displayFavoriteMeals();
  }

  Future<void> displayFavoriteMeals() async {
    emit(MealsLoading());
    final returnedData = await sl<GetFavoritesMealUseCase>().call();
    returnedData.fold(
      (error) => emit(MealsLoadingFailure(message: mapFailureToMessage(error))),
      (data) => emit(MealsLoadingSuccess(meals: data)),
    );
  }

  Future<void> toggleFavorite(MealEntity meal, BuildContext context) async {
    final currentState = state;
    if (currentState is MealsLoadingSuccess) {
      final updatedMeals = List<MealEntity>.from(currentState.meals);
      final isFavorite = updatedMeals.any((m) => m.mealId == meal.mealId);

      if (isFavorite) {
        updatedMeals.removeWhere((m) => m.mealId == meal.mealId);
      } else {
        updatedMeals.add(meal);
      }

      // Natychmiastowa aktualizacja UI
      emit(MealsLoadingSuccess(meals: updatedMeals));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite
              ? context.l10n.deteledFromFavorites
              : context.l10n.addedToFavorites),
          duration: const Duration(seconds: 1),
        ),
      );

      // Aktualizacja Firestore
      await sl<AddOrRemoveFavoriteMealUseCase>().call(params: meal);
    }
  }
}
