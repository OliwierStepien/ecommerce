import 'package:mealapp/domain/meal/entity/meal.dart';

abstract class MealsDisplayState {}

class MealsInitialState extends MealsDisplayState {}

class MealsLoading extends MealsDisplayState {}

class MealsLoaded extends MealsDisplayState {
  final List<MealEntity> meals;

  MealsLoaded({required this.meals});
}

class LoadMealsFailure extends MealsDisplayState {}
