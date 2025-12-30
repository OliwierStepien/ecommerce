import 'package:mealapp/data/grocery/model/grocery_model.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';

class GroceryMapper {
  static GroceryEntity toEntity(GroceryModel model) {
    return GroceryEntity(
      groceryItemName: model.groceryItemName,
      groceryItemId: model.groceryItemId,
      groceryItemCategory: model.groceryItemCategory,
    );
  }

  static GroceryModel toModel(GroceryEntity entity) {
    return GroceryModel(
      groceryItemName: entity.groceryItemName,
      groceryItemId: entity.groceryItemId,
      groceryItemCategory: entity.groceryItemCategory,
    );
  }
}