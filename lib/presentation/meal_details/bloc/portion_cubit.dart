import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class PortionCubit extends Cubit<int> {
  final MealEntity meal;
  final int basePortion;

  PortionCubit(this.meal)
      : basePortion = meal.portion,
        super(1); // multiplier startuje od 1

  void increase() => emit(state + 1);

  void decrease() {
    if (state > 1) emit(state - 1);
  }

  int get currentPortion => basePortion * state;

  /// Zwraca MealEntity z przeskalowaną liczbą porcji
  MealEntity updatedMeal() {
    return meal.copyWith(portion: currentPortion);
  }
}