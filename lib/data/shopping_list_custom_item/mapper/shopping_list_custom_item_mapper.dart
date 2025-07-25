import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';

class ShoppingListCustomItemMapper {
  // Model -> Entity
  static ShoppingListCustomItemEntity toEntity(
      ShoppingListCustomItemModel model) {
    return ShoppingListCustomItemEntity(
      customItemId: model.customItemId,
      customItemName: model.customItemName,
      customItemCategory: model.customItemCategory,
    );
  }

  // Entity -> Model
  static ShoppingListCustomItemModel toModel(
      ShoppingListCustomItemEntity entity) {
    return ShoppingListCustomItemModel(
      customItemId: entity.customItemId,
      customItemName: entity.customItemName,
      customItemCategory: entity.customItemCategory,
      isSynced: false,
      isDeleted: false,
    );
  }
}
