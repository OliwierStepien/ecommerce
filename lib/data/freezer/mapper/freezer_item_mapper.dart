import 'package:mealapp/data/freezer/model/freezer_item_model.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';

class FreezerItemMapper {
  static FreezerItemEntity toEntity(FreezerItemModel m) => FreezerItemEntity(
        itemId: m.itemId,
        name: m.name,
        category: m.category,
      );

  static FreezerItemModel toModel(FreezerItemEntity e) => FreezerItemModel(
        itemId: e.itemId,
        name: e.name,
        category: e.category,
        isSynced: false,
        isDeleted: false,
      );
}
