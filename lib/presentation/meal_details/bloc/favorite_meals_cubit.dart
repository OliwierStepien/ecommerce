import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/meal/usecases/favourite/get_favorites_meal.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/service_locator.dart';

class FavoriteMealsCubit extends Cubit<MealsDisplayState> {
  FavoriteMealsCubit() : super(MealsInitialState());

  Future<void> displayFavoriteMeals() async {
    emit(MealsLoading());
    final returnedData = await sl<GetFavoritesMealUseCase>().call();
    returnedData.fold(
      (error) => emit(MealsLoadingFailure(message: mapFailureToMessage(error))),
      (data) => emit(MealsLoadingSuccess(meals: data)),
    );
  }

  void displayInitial() {
    emit(MealsInitialState());
  }
}
