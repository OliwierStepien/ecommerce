import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/remote/firebase_shopping_list_custom_item_service.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

class FirebaseShoppingListCustomItemRepositoryImpl
    implements ShoppingListCustomItemRepository {
  final FirebaseShoppingListCustomItemService
      _firebaseShoppingListCustomItemService;

  FirebaseShoppingListCustomItemRepositoryImpl(
      {required FirebaseShoppingListCustomItemService
          firebaseShoppingListCustomItemService})
      : _firebaseShoppingListCustomItemService =
            firebaseShoppingListCustomItemService;

  @override
  Future<Either<Failure, void>> addCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity) async {
    return handleFirestoreFailure(() async {
      await _firebaseShoppingListCustomItemService.addCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(
          shoppingListCustomItemEntity,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId) async {
    return handleFirestoreFailure(() async {
      await _firebaseShoppingListCustomItemService
          .removeCustomItemFromShoppingList(customItemId);
    });
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getCustomItemToShoppingList() async {
    return handleFirestoreFailure(() async {
      final returnedData = await _firebaseShoppingListCustomItemService
          .getCustomItemToShoppingList();
      return returnedData.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedChangesForShoppingListCustomItem() async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }

  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedShoppingListCustomItem() async {
    return handleFirestoreFailure(() async {
      final allMeals = await _firebaseShoppingListCustomItemService
          .getCustomItemToShoppingList();
      return allMeals.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
      String customItemId) async {
    return handleFirestoreFailure(() async {
      return;
    });
  }

  @override
  Future<Either<Failure, void>> restoreCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity) async {
    return handleFirestoreFailure(() async {
      await _firebaseShoppingListCustomItemService
          .restoreCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(shoppingListCustomItemEntity),
      );
    });
  }
}
