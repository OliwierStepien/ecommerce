import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/grocery/usecase/get_groceries.dart';
import 'package:mealapp/presentation/grocery/bloc/groceries_display_state.dart';

class GroceriesDisplayCubit extends Cubit<GroceriesDisplayState> {
  final GetGroceriesUseCase _useCase;

  GroceriesDisplayCubit({required GetGroceriesUseCase useCase})
      : _useCase = useCase,
        super(const GroceriesLoading());

  Future<void> loadGroceries() async {
    emit(const GroceriesLoading());
    final result = await _useCase.call(NoParams());
    result.fold(
      (failure) => emit(GroceriesLoadingFailure(message: mapFailureToMessage(failure))),
      (data) => emit(GroceriesLoadingSuccess(groceries: data)),
    );
  }
}