import 'package:equatable/equatable.dart';

class FreezerItemEntity extends Equatable {
  final String itemId;
  final String name;
  final String category;

  const FreezerItemEntity({
    required this.itemId,
    required this.name,
    required this.category,
  });

  FreezerItemEntity copyWith({
    String? itemId,
    String? name,
    String? category,
  }) {
    return FreezerItemEntity(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [itemId, name, category];
}