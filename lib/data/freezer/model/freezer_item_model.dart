import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

part 'freezer_item_model.g.dart';

@HiveType(typeId: HiveTypeIds.freezerItem)
class FreezerItemModel {
  @HiveField(0)
  final String itemId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final bool isSynced;

  @HiveField(4)
  final bool isDeleted;

  @HiveField(5, defaultValue: '')
  final String ownerUid;

  const FreezerItemModel({
    required this.itemId,
    required this.name,
    required this.category,
    required this.isSynced,
    required this.isDeleted,
    this.ownerUid = '',
  });

  FreezerItemModel copyWith({
    String? itemId,
    String? name,
    String? category,
    bool? isSynced,
    bool? isDeleted,
    String? ownerUid,
  }) {
    return FreezerItemModel(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'name': name,
        'category': category,
        'isDeleted': isDeleted,
        'ownerUid': ownerUid,
      };

  factory FreezerItemModel.fromMap(Map<String, dynamic> map) {
    return FreezerItemModel(
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      ownerUid: map['ownerUid'] ?? '',
    );
  }
}