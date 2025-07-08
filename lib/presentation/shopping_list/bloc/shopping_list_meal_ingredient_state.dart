import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

abstract class ShoppingListMealIngredientState extends Equatable {
  const ShoppingListMealIngredientState();

  @override
  List<Object?> get props => [];
}

class ShoppingListInitial extends ShoppingListMealIngredientState {}

class ShoppingListLoading extends ShoppingListMealIngredientState {}

class ShoppingListLoaded extends ShoppingListMealIngredientState {
  final List<MealEntity> meals;

  const ShoppingListLoaded(this.meals);

  @override
  List<Object?> get props => [meals];
}

class ShoppingListError extends ShoppingListMealIngredientState {
  final String message;

  const ShoppingListError(this.message);

  @override
  List<Object?> get props => [message];
}

