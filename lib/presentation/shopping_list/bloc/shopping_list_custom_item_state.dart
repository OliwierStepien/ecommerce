import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';

/// 💾 Stan dla `ShoppingListCustomItemCubit`
sealed class ShoppingListCustomItemState extends Equatable {
  const ShoppingListCustomItemState();

  @override
  List<Object?> get props => [];
}

/// 🟡 Stan początkowy – dane jeszcze niezaładowane
class ShoppingListCustomItemInitial extends ShoppingListCustomItemState {
  const ShoppingListCustomItemInitial();
}

/// 🔄 Trwa ładowanie listy niestandardowych składników
class ShoppingListCustomItemLoading extends ShoppingListCustomItemState {
  const ShoppingListCustomItemLoading();
}

/// ✅ Załadowano listę składników niestandardowych
class ShoppingListCustomItemLoaded extends ShoppingListCustomItemState {
  final List<ShoppingListCustomItemEntity> items;

  const ShoppingListCustomItemLoaded({required this.items});

  ShoppingListCustomItemLoaded copyWith({
    List<ShoppingListCustomItemEntity>? items,
  }) {
    return ShoppingListCustomItemLoaded(
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [items];
}

/// ❌ Wystąpił błąd
class ShoppingListCustomItemError extends ShoppingListCustomItemState {
  final String message;

  const ShoppingListCustomItemError({required this.message});

  @override
  List<Object?> get props => [message];
}