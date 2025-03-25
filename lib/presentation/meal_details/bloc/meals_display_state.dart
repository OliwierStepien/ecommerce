import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';

abstract class MealsDisplayState extends Equatable {}
@override
List<Object?> get props => [];

class MealsInitialState extends MealsDisplayState {
  @override
  List<Object?> get props => [];
}

class MealsLoading extends MealsDisplayState {
  @override
  List<Object?> get props => [];
}

class MealsLoadingSuccess extends MealsDisplayState {
  final List<MealEntity> meals;

  MealsLoadingSuccess({required this.meals});
  @override
  List<Object?> get props => [meals];
}

class MealsLoadingFailure extends MealsDisplayState {
  final String message;

  MealsLoadingFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
