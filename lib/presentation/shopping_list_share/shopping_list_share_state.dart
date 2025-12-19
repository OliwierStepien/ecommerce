// presentation/shopping_list_share/bloc/shopping_list_share_state.dart
import 'package:equatable/equatable.dart';

sealed class ShoppingListShareState extends Equatable {
  const ShoppingListShareState();

  @override
  List<Object?> get props => [];
}

class ShoppingListShareIdle extends ShoppingListShareState {
  const ShoppingListShareIdle();
}

class ShoppingListShareLoading extends ShoppingListShareState {
  const ShoppingListShareLoading();
}

class ShoppingListShareSuccess extends ShoppingListShareState {
  final String message;
  const ShoppingListShareSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ShoppingListShareFailure extends ShoppingListShareState {
  final String message;
  const ShoppingListShareFailure(this.message);

  @override
  List<Object?> get props => [message];
}