import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/usecases/add_or_remove_favorite_meal.dart';
import 'package:mealapp/domain/meal/usecases/is_favorite.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteIconCubit extends Cubit<bool> {
  FavoriteIconCubit() : super(false);

  Future<void> isFavorite(String mealId) async {
    final result = await sl<IsFavoriteUseCase>().call(params: mealId);
    emit(result);
  }

  Future<void> onTap(MealEntity meal) async {
    emit(!state);

    final result =
        await sl<AddOrRemoveFavoriteMealUseCase>().call(params: meal);

    result.fold(
      (error) {
        emit(!state);
      },
      (data) async {
        final isNowFavorite =
            await sl<IsFavoriteUseCase>().call(params: meal.mealId);
        emit(isNowFavorite);
      },
    );
  }
}
