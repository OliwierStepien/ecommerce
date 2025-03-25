import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_state.dart';
import 'package:mealapp/domain/category/usecases/get_categories.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesDisplayCubit extends Cubit<CategoriesDisplayState> {
  CategoriesDisplayCubit() : super(CategoriesLoading());

  Future<void> displayCategories() async {
    final returnedData = await sl<GetCategoriesUseCase>().call();
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