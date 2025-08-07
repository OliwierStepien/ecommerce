import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/usecase/usecase.dart';

class MealsDisplayCubit extends Cubit<MealsDisplayState> {
  final UseCase useCase;

  MealsDisplayCubit({required this.useCase}) : super(MealsInitialState());

  Future<void> displayMeals({dynamic params}) async {
    if (isClosed) return;
    final overallStopwatch = Stopwatch()..start();
    debugPrint('[MealsDisplayCubit] displayMeals: start params=$params');

    emit(MealsLoading());

    final useCaseStopwatch = Stopwatch()..start();
    final returnedData = await useCase.call(params: params);
    useCaseStopwatch.stop();
    debugPrint(
        '[MealsDisplayCubit] displayMeals: use case call took ${useCaseStopwatch.elapsedMilliseconds}ms');

    if (isClosed) return;

    returnedData.fold(
      (error) {
        final emitStopwatch = Stopwatch()..start();
        if (!isClosed) {
          emit(MealsLoadingFailure(message: mapFailureToMessage(error)));
        }
        emitStopwatch.stop();
        debugPrint(
            '[MealsDisplayCubit] displayMeals: emitted failure in ${emitStopwatch.elapsedMilliseconds}ms');
      },
      (data) {
        final emitStopwatch = Stopwatch()..start();
        if (!isClosed) emit(MealsLoadingSuccess(meals: data));
        emitStopwatch.stop();
        debugPrint(
            '[MealsDisplayCubit] displayMeals: emitted success in ${emitStopwatch.elapsedMilliseconds}ms, count=${(data as List).length}');
      },
    );

    overallStopwatch.stop();
    debugPrint(
        '[MealsDisplayCubit] displayMeals: total flow time = ${overallStopwatch.elapsedMilliseconds}ms');
  }

  void displayInitial() {
    emit(MealsInitialState());
  }
}