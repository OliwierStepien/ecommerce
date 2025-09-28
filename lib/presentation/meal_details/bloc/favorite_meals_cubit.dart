import 'package:flutter/material.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/usecase/add_favorite_meal.dart';
import 'package:mealapp/domain/favorite_meal/usecase/remove_favorite_meal.dart';
import 'package:mealapp/domain/favorite_meal/usecase/get_favorites_meal.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteMealsCubit extends Cubit<MealsDisplayState> {
  final GetFavoritesMealUseCase getFavoritesMealUseCase;
  final AddFavoriteMealUseCase addFavoriteMealUseCase;
  final RemoveFavoriteMealUseCase removeFavoriteMealUseCase;

  FavoriteMealsCubit(
      {required this.getFavoritesMealUseCase,
      required this.addFavoriteMealUseCase,
      required this.removeFavoriteMealUseCase})
      : super(const MealsInitialState()) {
    displayFavoriteMeals();
  }

  Future<void> displayFavoriteMeals() async {
    emit(const MealsLoading());
    final returnedData = await getFavoritesMealUseCase.call();
    returnedData.fold(
      (error) => emit(MealsLoadingFailure(message: mapFailureToMessage(error))),
      (data) => emit(MealsLoadingSuccess(
        meals: data.map((fav) => fav.meal).toList(),
      )),
    );
  }

  Future<void> toggleFavorite(MealEntity meal, BuildContext context) async {
    final currentState = state;
    if (currentState is MealsLoadingSuccess) {
      final updatedMeals = List<MealEntity>.from(currentState.meals);
      final isFavorite = updatedMeals.any((m) => m.mealId == meal.mealId);

      if (isFavorite) {
        updatedMeals.removeWhere((m) => m.mealId == meal.mealId);
        await removeFavoriteMealUseCase.call(params: meal.mealId);
      } else {
        updatedMeals.add(meal);
        await addFavoriteMealUseCase.call(
          params: FavoriteMealEntity(meal: meal),
        );
      }

      emit(MealsLoadingSuccess(meals: updatedMeals));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorite
                ? context.l10n.deteledFromFavorites
                : context.l10n.addedToFavorites),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
