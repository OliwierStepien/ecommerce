import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealsDisplayCubit extends Cubit<MealsDisplayState> {
  final UseCase useCase;

  MealsDisplayCubit({required this.useCase}) : super(MealsInitialState());

  Future<void> displayMeals({dynamic params}) async {
    emit(MealsLoading());
    final returnedData = await useCase.call(params: params);
    returnedData.fold(
      (error) => emit(MealsLoadingFailure(message: mapFailureToMessage(error))),
      (data) => emit(MealsLoadingSuccess(meals: data)),
    );
  }

  void displayInitial() {
    emit(MealsInitialState());
  }
}