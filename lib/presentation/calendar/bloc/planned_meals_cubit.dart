import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class PlannedMealsCubit extends Cubit<Map<DateTime, List<MealEntity>>> {
  PlannedMealsCubit() : super({});

  void addMeal(DateTime day, MealEntity meal) {
    final meals = [...(state[day] ?? <MealEntity>[])]; // 👈 rzutowanie
    meals.add(meal);
    emit({...state, day: meals});
  }

  void removeMeal(DateTime day, MealEntity meal) {
    final meals = [...(state[day] ?? <MealEntity>[])]; // 👈 rzutowanie
    meals.remove(meal);
    if (meals.isEmpty) {
      final newState = Map.of(state)..remove(day);
      emit(newState);
    } else {
      emit({...state, day: meals});
    }
  }
}