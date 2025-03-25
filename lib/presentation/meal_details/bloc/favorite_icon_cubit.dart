import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/usecases/favourite/add_or_remove_favorite_meal.dart';
import 'package:mealapp/domain/meal/usecases/favourite/is_favorite.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteIconCubit extends Cubit<bool> {
  FavoriteIconCubit() : super(false);

  Future<void> isFavorite(String mealId) async {
    final result = await sl<IsFavoriteUseCase>().call(params: mealId);
    result.fold(
      (failure) {
        // Możesz tutaj obsłużyć błąd, np. wyświetlić komunikat lub zalogować go
        emit(false);
      },
      (isFavorite) {
        emit(isFavorite);
      },
    );
  }

  Future<void> onTap(MealEntity meal) async {
    emit(!state);

    final result = await sl<AddOrRemoveFavoriteMealUseCase>().call(params: meal);

    result.fold(
      (failure) {
        emit(!state);
        // Możesz tutaj obsłużyć błąd, np. wyświetlić komunikat
      },
      (success) async {
        final isNowFavoriteResult = await sl<IsFavoriteUseCase>().call(params: meal.mealId);
        isNowFavoriteResult.fold(
          (failure) {
            emit(false);
          },
          (isNowFavorite) {
            emit(isNowFavorite);
          },
        );
      },
    );
  }
}