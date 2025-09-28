import 'package:flutter/material.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/usecase/usecase.dart';

class MealsDisplayCubit extends Cubit<MealsDisplayState> {
  final UseCase useCase;

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  /// kontrola focusu tylko raz
  bool _hasRequestedFocus = false;

  MealsDisplayCubit({required this.useCase}) : super(const MealsInitialState());

  void requestFocusOnce() {
    if (!_hasRequestedFocus) {
      focusNode.requestFocus();
      _hasRequestedFocus = true;
    }
  }

  Future<void> displayMeals({dynamic params}) async {
    if (isClosed) return;
    emit(const MealsLoading());
    final returnedData = await useCase.call(params: params);
    if (isClosed) return;

    returnedData.fold(
      (error) => emit(MealsLoadingFailure(message: mapFailureToMessage(error))),
      (data) => emit(MealsLoadingSuccess(meals: data)),
    );
  }

  void displayInitial() => emit(const MealsInitialState());

  @override
  Future<void> close() {
    controller.dispose();
    focusNode.dispose();
    return super.close();
  }
}