import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';

sealed class GroceriesDisplayState extends Equatable {
  const GroceriesDisplayState();

  @override
  List<Object?> get props => [];
}

class GroceriesLoading extends GroceriesDisplayState {
  const GroceriesLoading();
}

class GroceriesLoadingSuccess extends GroceriesDisplayState {
  final List<GroceryEntity> groceries;

  const GroceriesLoadingSuccess({required this.groceries});

  @override
  List<Object?> get props => [groceries];
}

class GroceriesLoadingFailure extends GroceriesDisplayState {
  final String message;

  const GroceriesLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}