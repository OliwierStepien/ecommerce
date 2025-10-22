import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_state.dart';
import 'package:mealapp/domain/category/usecase/get_categories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesDisplayCubit extends Cubit<CategoriesDisplayState> {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoriesDisplayCubit({required this.getCategoriesUseCase})
      : super(const CategoriesLoading());

  Future<void> displayCategories() async {
    final returnedData = await getCategoriesUseCase.call(NoParams());
    returnedData.fold(
      (error) {
        emit(CategoriesLoadingFailure(message: mapFailureToMessage(error)));
      },
      (data) {
        emit(CategoriesLoadingSuccess(categories: data));
      },
    );
  }
}
