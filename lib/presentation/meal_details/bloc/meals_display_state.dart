import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

sealed class MealsDisplayState extends Equatable {
  const MealsDisplayState();
  @override
  List<Object?> get props => [];
}

class MealsInitialState extends MealsDisplayState {
  const MealsInitialState();
}

class MealsLoading extends MealsDisplayState {
  const MealsLoading();
}

class MealsLoadingSuccess extends MealsDisplayState {
  final List<MealEntity> meals;

  const MealsLoadingSuccess({required this.meals});

  @override
  List<Object?> get props => [meals];
}

class MealsLoadingFailure extends MealsDisplayState {
  final String message;

  const MealsLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
