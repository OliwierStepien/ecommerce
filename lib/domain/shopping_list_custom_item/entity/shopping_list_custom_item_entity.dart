import 'package:equatable/equatable.dart';

class ShoppingListCustomItemEntity extends Equatable {
  final String customItemId;
  final String customItemName;
  final String customItemCategory;

  const ShoppingListCustomItemEntity({
    required this.customItemId,
    required this.customItemName,
    required this.customItemCategory,
  });

  @override
  List<Object?> get props => [
        customItemId,
        customItemName,
        customItemCategory,
      ];
}
