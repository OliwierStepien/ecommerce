import 'package:equatable/equatable.dart';

class FreezerItemEntity extends Equatable {
  final String itemId;
  final String name;
  final String category;

  /// ✅ ważne: metadane źródła
  final String sourceOwnerUid;
  final String sourceItemId;

  const FreezerItemEntity({
    required this.itemId,
    required this.name,
    required this.category,
    this.sourceOwnerUid = '',
    this.sourceItemId = '',
  });

  FreezerItemEntity copyWith({
    String? itemId,
    String? name,
    String? category,
    String? sourceOwnerUid,
    String? sourceItemId,
  }) {
    return FreezerItemEntity(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
      sourceOwnerUid: sourceOwnerUid ?? this.sourceOwnerUid,
      sourceItemId: sourceItemId ?? this.sourceItemId,
    );
  }

  @override
  List<Object?> get props => [itemId, name, category, sourceOwnerUid, sourceItemId];
}