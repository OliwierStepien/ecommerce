import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

/// Cubit, który filtruje posiłki w zależności od zaznaczonych kategorii.
class MealsFilterCubit extends Cubit<List<MealEntity>> {
  final List<MealEntity> allMeals;

  MealsFilterCubit({required this.allMeals}) : super(allMeals);

  /// Filtruje po wielu kategoriach (można wybrać kilka).
  void filterByCategories(Set<String> selectedCategoryIds) {
    if (selectedCategoryIds.isEmpty) {
      emit(allMeals);
      return;
    }

    final filtered = allMeals.where((meal) {
      return meal.categoryId.any(selectedCategoryIds.contains);
    }).toList();

    emit(filtered);
  }

  void reset() => emit(allMeals);
}