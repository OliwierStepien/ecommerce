import 'package:equatable/equatable.dart';

/// 💾 Stan dla ShoppingListMealIngredientCubit
sealed class ShoppingListMealIngredientState extends Equatable {
  const ShoppingListMealIngredientState();

  @override
  List<Object?> get props => [];
}

/// 🟡 Stan początkowy – dane jeszcze niezaładowane
class ShoppingListMealIngredientInitial extends ShoppingListMealIngredientState {
  const ShoppingListMealIngredientInitial();
}

/// 🔄 Trwa ładowanie listy składników z posiłków
class ShoppingListMealIngredientLoading extends ShoppingListMealIngredientState {
  const ShoppingListMealIngredientLoading();
}

/// ✅ Załadowano listę składników z posiłków
class ShoppingListMealIngredientLoaded extends ShoppingListMealIngredientState {
  final List<Map<String, dynamic>> items;

  const ShoppingListMealIngredientLoaded({required this.items});

  ShoppingListMealIngredientLoaded copyWith({
    List<Map<String, dynamic>>? items,
  }) {
    return ShoppingListMealIngredientLoaded(
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [items];
}

/// ❌ Wystąpił błąd
class ShoppingListMealIngredientError extends ShoppingListMealIngredientState {
  final String message;

  const ShoppingListMealIngredientError({required this.message});

  @override
  List<Object?> get props => [message];
}