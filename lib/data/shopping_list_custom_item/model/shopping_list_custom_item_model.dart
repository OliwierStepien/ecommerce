import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

part 'shopping_list_custom_item_model.g.dart';

@HiveType(typeId: HiveTypeIds.shoppingListCustomItem)
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

  /// UID właściciela TEJ kolekcji (u kogo leży dokument)
  @HiveField(5, defaultValue: '')
  final String ownerUid;

  /// UID źródła (kto jest oryginalnym właścicielem)
  @HiveField(6, defaultValue: '')
  final String sourceOwnerUid;

  /// ID dokumentu u źródła (oryginalne customItemId u sourceOwnerUid)
  @HiveField(7, defaultValue: '')
  final String sourceItemId;

  /// Lista UID, którzy mogą aktualizować dokument (do “odsyłania zmian”)
  @HiveField(8, defaultValue: <String>[])
  final List<String> editors;

  const ShoppingListCustomItemModel({
    required this.customItemId,
    required this.customItemName,
    required this.customItemCategory,
    required this.isSynced,
    required this.isDeleted,
    this.ownerUid = '',
    this.sourceOwnerUid = '',
    this.sourceItemId = '',
    this.editors = const <String>[],
  });

  ShoppingListCustomItemModel copyWith({
    String? customItemId,
    String? customItemName,
    String? customItemCategory,
    bool? isSynced,
    bool? isDeleted,
    String? ownerUid,
    String? sourceOwnerUid,
    String? sourceItemId,
    List<String>? editors,
  }) {
    return ShoppingListCustomItemModel(
      customItemId: customItemId ?? this.customItemId,
      customItemName: customItemName ?? this.customItemName,
      customItemCategory: customItemCategory ?? this.customItemCategory,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      ownerUid: ownerUid ?? this.ownerUid,
      sourceOwnerUid: sourceOwnerUid ?? this.sourceOwnerUid,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      editors: editors ?? this.editors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customItemId': customItemId,
      'customItemName': customItemName,
      'customItemCategory': customItemCategory,
      'isDeleted': isDeleted,
      'ownerUid': ownerUid,
      'sourceOwnerUid': sourceOwnerUid,
      'sourceItemId': sourceItemId,
      'editors': editors,
    };
  }

  factory ShoppingListCustomItemModel.fromMap(Map<String, dynamic> map) {
    final rawEditors = map['editors'];
    final editors = (rawEditors is List)
        ? rawEditors.whereType<String>().toList()
        : <String>[];

    return ShoppingListCustomItemModel(
      customItemId: (map['customItemId'] ?? '') as String,
      customItemName: (map['customItemName'] ?? '') as String,
      customItemCategory: (map['customItemCategory'] ?? '') as String,
      isSynced: (map['isSynced'] ?? false) as bool,
      isDeleted: (map['isDeleted'] ?? false) as bool,
      ownerUid: (map['ownerUid'] ?? '') as String,
      sourceOwnerUid: (map['sourceOwnerUid'] ?? '') as String,
      sourceItemId: (map['sourceItemId'] ?? '') as String,
      editors: editors,
    );
  }
}