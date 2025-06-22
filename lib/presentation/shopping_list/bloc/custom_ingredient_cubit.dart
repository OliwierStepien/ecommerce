import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_state.dart';
import 'package:mealapp/service_locator.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';

class CustomIngredientCubit extends Cubit<CustomIngredientState> {
  CustomIngredientCubit() : super(const CustomIngredientLoading());

  Future<void> loadCategories() async {
    final result = await sl<GetAllIngredientsUseCase>().call();

    result.fold(
      (failure) {
        emit(CustomIngredientError(message: mapFailureToMessage(failure)));
      },
      (ingredients) {
        final uniqueCategories = ingredients
            .map((i) => i.ingredientCategory)
            .where((cat) => cat.trim().isNotEmpty)
            .toSet()
            .toList();

        if (!uniqueCategories.contains('Inne')) {
          uniqueCategories.insert(0, 'Inne');
        }

        emit(CustomIngredientLoaded(categories: uniqueCategories));
      },
    );
  }
}