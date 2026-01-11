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

  /// UID właściciela TEJ kolekcji (czyli “u kogo leży dokument” w Firestore/Hive)
  @HiveField(5, defaultValue: '')
  final String ownerUid;

  /// UID źródła (kto jest “oryginalnym właścicielem” / od kogo item pochodzi)
  @HiveField(6, defaultValue: '')
  final String sourceOwnerUid;

  /// ID dokumentu u źródła (oryginalne itemId u sourceOwnerUid)
  @HiveField(7, defaultValue: '')
  final String sourceItemId;

  /// Lista UID, którzy mogą aktualizować ten dokument (do “odsyłania zmian”)
  @HiveField(8, defaultValue: <String>[])
  final List<String> editors;

  const FreezerItemModel({
    required this.itemId,
    required this.name,
    required this.category,
    required this.isSynced,
    required this.isDeleted,
    this.ownerUid = '',
    this.sourceOwnerUid = '',
    this.sourceItemId = '',
    this.editors = const <String>[],
  });

  FreezerItemModel copyWith({
    String? itemId,
    String? name,
    String? category,
    bool? isSynced,
    bool? isDeleted,
    String? ownerUid,
    String? sourceOwnerUid,
    String? sourceItemId,
    List<String>? editors,
  }) {
    return FreezerItemModel(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      ownerUid: ownerUid ?? this.ownerUid,
      sourceOwnerUid: sourceOwnerUid ?? this.sourceOwnerUid,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      editors: editors ?? this.editors,
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'name': name,
        'category': category,
        'isDeleted': isDeleted,
        'ownerUid': ownerUid,
        'sourceOwnerUid': sourceOwnerUid,
        'sourceItemId': sourceItemId,
        'editors': editors,
      };

  factory FreezerItemModel.fromMap(Map<String, dynamic> map) {
    final rawEditors = map['editors'];
    final editors = (rawEditors is List)
        ? rawEditors.whereType<String>().toList()
        : <String>[];

    return FreezerItemModel(
      itemId: (map['itemId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      isSynced: (map['isSynced'] ?? false) as bool,
      isDeleted: (map['isDeleted'] ?? false) as bool,
      ownerUid: (map['ownerUid'] ?? '') as String,
      sourceOwnerUid: (map['sourceOwnerUid'] ?? '') as String,
      sourceItemId: (map['sourceItemId'] ?? '') as String,
      editors: editors,
    );
  }
}