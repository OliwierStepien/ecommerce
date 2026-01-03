import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';

sealed class FreezerItemState extends Equatable {
  const FreezerItemState();
  @override
  List<Object?> get props => [];
}

class FreezerItemInitial extends FreezerItemState {
  const FreezerItemInitial();
}

class FreezerItemLoading extends FreezerItemState {
  const FreezerItemLoading();
}

class FreezerItemLoaded extends FreezerItemState {
  final List<FreezerItemEntity> items;
  const FreezerItemLoaded({required this.items});

  FreezerItemLoaded copyWith({List<FreezerItemEntity>? items}) =>
      FreezerItemLoaded(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}

class FreezerItemError extends FreezerItemState {
  final String message;
  const FreezerItemError({required this.message});

  @override
  List<Object?> get props => [message];
}