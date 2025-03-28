import 'package:dartz/dartz.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';

import '../../../core/usecase/usecase.dart';

class ButtonStateCubit extends Cubit<ButtonState> {
  ButtonStateCubit() : super(ButtonInitialState());

  Future<void> execute({dynamic params, required UseCase usecase}) async {
    emit(ButtonLoadingState());

    Either returnedData = await usecase.call(params: params);
    returnedData.fold(
      (failure) {
        final errorMessage = mapFailureToMessage(failure as Failure);
        emit(ButtonFailureState(errorMessage: errorMessage));
      },
      (successMessage) {
        emit(ButtonSuccessState(successMessage as String));
      },
    );
  }
}
