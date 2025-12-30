import 'package:equatable/equatable.dart';

class GroceryEntity extends Equatable {
  final String groceryItemName;
  final String groceryItemId;
  final String groceryItemCategory;

  const GroceryEntity({
    required this.groceryItemName,
    required this.groceryItemId,
    required this.groceryItemCategory,
  });

  @override
  List<Object?> get props => [groceryItemName, groceryItemId, groceryItemCategory];
}