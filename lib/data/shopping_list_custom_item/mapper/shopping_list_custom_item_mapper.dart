import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';

class ShoppingListCustomItemMapper {
  static ShoppingListCustomItemEntity toEntity(ShoppingListCustomItemModel model) {
    return ShoppingListCustomItemEntity(
      customItemId: model.customItemId,
      customItemName: model.customItemName,
      customItemCategory: model.customItemCategory,
      isChecked: model.isChecked,
    );
  }

  /// Dla nowych lokalnych itemów ustawiamy:
  /// - sourceOwnerUid = aktualny user (oryginał)
  /// - sourceItemId   = customItemId
  /// - editors        = [uid]
  static ShoppingListCustomItemModel toModel(
    ShoppingListCustomItemEntity entity, {
    FirebaseAuth? auth,
  }) {
    final a = auth ?? FirebaseAuth.instance;
    final uid = a.currentUser?.uid ?? '';

    return ShoppingListCustomItemModel(
      customItemId: entity.customItemId,
      customItemName: entity.customItemName,
      customItemCategory: entity.customItemCategory,
      isSynced: false,
      isDeleted: false,
      ownerUid: uid,
      sourceOwnerUid: uid,
      sourceItemId: entity.customItemId,
      editors: uid.isEmpty ? const <String>[] : <String>[uid],
      isChecked: entity.isChecked,
    );
  }
}