import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

part 'grocery_model.g.dart';

@HiveType(typeId: HiveTypeIds.grocery)
class GroceryModel {
  @HiveField(0)
  final String groceryItemName;

  @HiveField(1)
  final String groceryItemId;

  @HiveField(2)
  final String groceryItemCategory;

  GroceryModel({
    required this.groceryItemName,
    required this.groceryItemId,
    required this.groceryItemCategory,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groceryItemName': groceryItemName,
      'groceryItemId': groceryItemId,
      'groceryItemCategory': groceryItemCategory,
    };
  }

  factory GroceryModel.fromMap(Map<String, dynamic> map) {
    return GroceryModel(
      groceryItemName: (map['groceryItemName'] ?? '') as String,
      groceryItemId: (map['groceryItemId'] ?? '') as String,
      groceryItemCategory: (map['groceryItemCategory'] ?? 'Inne') as String,
    );
  }
}