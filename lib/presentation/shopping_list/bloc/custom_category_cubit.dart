import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/ingredient/usecase/get_all_ingredients.dart';
import 'package:mealapp/presentation/shopping_list/bloc/custom_ingredient_state.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';

class CustomCategoryCubit extends Cubit<CustomIngredientState> {
  final GetAllIngredientsUseCase getAllIngredientsUseCase;
  final TextEditingController nameController = TextEditingController();
  String selectedCategory = 'Inne';

  CustomCategoryCubit(this.getAllIngredientsUseCase)
      : super(const CustomIngredientLoading()) {
    loadCategories();
    nameController.addListener(_onTextChanged);
  }

  Future<void> loadCategories() async {
    emit(const CustomIngredientLoading());
    final result = await getAllIngredientsUseCase();

    result.fold(
      (failure) => emit(CustomIngredientError(message: mapFailureToMessage(failure))),
      (ingredients) {
        final categories = ingredients
            .map((e) => e.ingredientCategory.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

        if (!categories.contains('Inne')) categories.insert(0, 'Inne');

        selectedCategory = 'Inne';
        emit(CustomIngredientLoaded(categories: categories));
      },
    );
  }

  void updateCategory(String? category) {
    selectedCategory = category ?? 'Inne';
    if (state is CustomIngredientLoaded) {
      emit((state as CustomIngredientLoaded).copyWith());
    }
  }

  void _onTextChanged() {
    if (state is CustomIngredientLoaded) {
      emit((state as CustomIngredientLoaded).copyWith(
        inputText: nameController.text,
      ));
    }
  }

  void clearForm() {
    nameController.clear();
    selectedCategory = 'Inne';
    if (state is CustomIngredientLoaded) {
      emit((state as CustomIngredientLoaded).copyWith());
    }
  }

  ShoppingListCustomItemEntity? getCustomIngredient() {
    final name = nameController.text.trim();
    if (name.isEmpty) return null;
    return ShoppingListCustomItemEntity(
      customItemId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      customItemName: name,
      customItemCategory: selectedCategory,
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}