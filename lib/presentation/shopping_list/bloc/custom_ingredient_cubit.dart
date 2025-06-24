import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_state.dart';

class CustomIngredientCubit extends Cubit<CustomIngredientState> {
  final GetAllIngredientsUseCase getAllIngredientsUseCase;
  final TextEditingController nameController = TextEditingController();
  String? selectedCategory;

  CustomIngredientCubit(this.getAllIngredientsUseCase)
      : super(const CustomIngredientLoading()) {
    loadCategories();
    nameController.addListener(_onTextChanged);
  }

  Future<void> loadCategories() async {
    emit(const CustomIngredientLoading());
    final result = await getAllIngredientsUseCase();

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

        selectedCategory = 'Inne';
        emit(CustomIngredientLoaded(categories: uniqueCategories));
      },
    );
  }

  void updateCategory(String? category) {
    selectedCategory = category;
    if (state is CustomIngredientLoaded) {
      emit((state as CustomIngredientLoaded).copyWith());
    }
  }

  void _onTextChanged() {
    if (state is CustomIngredientLoaded) {
      final newText = nameController.text;
      emit((state as CustomIngredientLoaded).copyWith(inputText: newText));
    }
  }

  void clearForm() {
    nameController.clear();
    selectedCategory = 'Inne';
    if (state is CustomIngredientLoaded) {
      emit((state as CustomIngredientLoaded).copyWith());
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}