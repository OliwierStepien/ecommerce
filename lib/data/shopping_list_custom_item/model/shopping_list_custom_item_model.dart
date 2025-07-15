import 'package:hive/hive.dart';

part 'shopping_list_custom_item_model.g.dart';

@HiveType(typeId: 8)
class ShoppingListCustomItemModel {
  @HiveField(0)
  final String customItemId;
  @HiveField(1)
  final String customItemName;
  @HiveField(2)
  final String customItemCategory;
  @HiveField(3)
  final bool isSynced;
  @HiveField(4)
  final bool isDeleted;

  const ShoppingListCustomItemModel({
    required this.customItemId,
    required this.customItemName,
    required this.customItemCategory,
    required this.isSynced,
    required this.isDeleted,
  });

  ShoppingListCustomItemModel copyWith({
    String? customItemId,
    String? customItemName,
    String? customItemCategory,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return ShoppingListCustomItemModel(
      customItemId: customItemId ?? this.customItemId,
      customItemName: customItemName ?? this.customItemName,
      customItemCategory: customItemCategory ?? this.customItemCategory,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customItemId': customItemId,
      'customItemName': customItemName,
      'customItemCategory': customItemCategory,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory ShoppingListCustomItemModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListCustomItemModel(
      customItemId: map['customItemId'] as String,
      customItemName: map['customItemName'] as String,
      customItemCategory: map['customItemCategory'] as String,
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
