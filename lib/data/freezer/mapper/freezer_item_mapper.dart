import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/data/freezer/model/freezer_item_model.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';

class FreezerItemMapper {
  static FreezerItemEntity toEntity(FreezerItemModel m) => FreezerItemEntity(
        itemId: m.itemId,
        name: m.name,
        category: m.category,
        sourceOwnerUid: m.sourceOwnerUid,
        sourceItemId: m.sourceItemId,
      );

  /// ✅ Dla nowych lokalnych itemów:
  /// - sourceOwnerUid/sourceItemId ustawiamy na mój uid i itemId
  ///
  /// ✅ Dla itemów “zdalnych / udostępnionych”:
  /// - JEŚLI entity ma sourceOwnerUid/sourceItemId -> zachowujemy je (NIE resetujemy na mój uid)
  static FreezerItemModel toModel(FreezerItemEntity e, {FirebaseAuth? auth}) {
    final a = auth ?? FirebaseAuth.instance;
    final uid = a.currentUser?.uid ?? '';

    final resolvedSourceOwnerUid =
        e.sourceOwnerUid.isNotEmpty ? e.sourceOwnerUid : uid;
    final resolvedSourceItemId =
        e.sourceItemId.isNotEmpty ? e.sourceItemId : e.itemId;

    final editors = uid.isEmpty ? const <String>[] : <String>[uid];

    return FreezerItemModel(
      itemId: e.itemId,
      name: e.name,
      category: e.category,
      isSynced: false,
      isDeleted: false,
      ownerUid: uid,

      // ✅ kluczowe: NIE psujemy źródła
      sourceOwnerUid: resolvedSourceOwnerUid,
      sourceItemId: resolvedSourceItemId,

      // to jest “lokalne” editors – realne editors do oryginału i tak dopisujesz w share service
      editors: editors,
    );
  }
}