import 'package:equatable/equatable.dart';

// Klasa reprezentująca encję składnika własnego (czysta struktura domenowa)
class ShoppingListCustomItemEntity extends Equatable {
  final String customItemId;
  final String customItemName;
  final String customItemCategory;

  const ShoppingListCustomItemEntity({
    required this.customItemId,
    required this.customItemName,
    required this.customItemCategory,
  });

  ShoppingListCustomItemEntity copyWith({
    String? customItemId,
    String? customItemName,
    String? customItemCategory,
  }) {
    return ShoppingListCustomItemEntity(
      customItemId: customItemId ?? this.customItemId,
      customItemName: customItemName ?? this.customItemName,
      customItemCategory: customItemCategory ?? this.customItemCategory,
    );
  }

  // Equatable pozwala na łatwe porównywanie obiektów po wartości (potrzebne np. w BLoC)
  @override
  List<Object?> get props => [
        customItemId,
        customItemName,
        customItemCategory,
      ];
}
