import 'package:equatable/equatable.dart';

// Klasa reprezentująca encję składnika własnego (czysta struktura domenowa)
class ShoppingListCustomItemEntity extends Equatable {
  final String customItemId;
  final String customItemName;
  final String customItemCategory;

  /// ✅ metadane źródła (jak w freezer)
  final String sourceOwnerUid;
  final String sourceCustomItemId;

  /// ✅ czy pozycja została odhaczona jako kupiona
  final bool isChecked;

  const ShoppingListCustomItemEntity({
    required this.customItemId,
    required this.customItemName,
    required this.customItemCategory,
    this.sourceOwnerUid = '',
    this.sourceCustomItemId = '',
    this.isChecked = false,
  });

  ShoppingListCustomItemEntity copyWith({
    String? customItemId,
    String? customItemName,
    String? customItemCategory,
    String? sourceOwnerUid,
    String? sourceCustomItemId,
    bool? isChecked,
  }) {
    return ShoppingListCustomItemEntity(
      customItemId: customItemId ?? this.customItemId,
      customItemName: customItemName ?? this.customItemName,
      customItemCategory: customItemCategory ?? this.customItemCategory,
      sourceOwnerUid: sourceOwnerUid ?? this.sourceOwnerUid,
      sourceCustomItemId: sourceCustomItemId ?? this.sourceCustomItemId,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props => [
        customItemId,
        customItemName,
        customItemCategory,
        sourceOwnerUid,
        sourceCustomItemId,
        isChecked,
      ];
}