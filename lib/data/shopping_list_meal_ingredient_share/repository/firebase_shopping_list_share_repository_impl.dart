import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient_share/source/remote/firebase_shopping_list_share_service.dart';

class FirebaseShoppingListShareRepositoryImpl {
  final FirebaseShoppingListShareService _service;
  final HiveShoppingListMealIngredientService _hiveMeals;
  final HiveShoppingListCustomItemService _hiveCustom;

  FirebaseShoppingListShareRepositoryImpl(
    this._service,
    this._hiveMeals,
    this._hiveCustom,
  );

  /// Udostępnia **aktywne** pozycje z listy zakupów:
  /// - meal ingredients (ShoppingListMealIngredientModel)
  /// - custom items (ShoppingListCustomItemModel)
  /// Wszystko jednym przyciskiem / jedną akcją.
  Future<Either<Failure, void>> shareShoppingListWithFriend({
    required String friendUid,
  }) {
    return handleFirestoreFailure(() async {
      // 🥘 Składniki powiązane z posiłkami
      final allMeals = await _hiveMeals.getMealIngredientFromShoppingList();
      final toShareMeals =
          allMeals.where((m) => !m.isDeleted).toList(); // dodatkowe zabezpieczenie

      // 🧺 Własne produkty (custom items)
      final allCustom = await _hiveCustom.getCustomItemFromShoppingList();
      final toShareCustom =
          allCustom.where((c) => !c.isDeleted).toList(); // też na wszelki wypadek

      await _service.shareShoppingListWithFriend(
        friendUid: friendUid,
        mealItemsToShare: toShareMeals,
        customItemsToShare: toShareCustom,
      );
      return;
    });
  }

  /// Wariant selektywny — udostępnianie wybranych elementów.
  /// Domyślnie selekcja dotyczy tylko `ShoppingListMealIngredientModel`,
  /// ale można opcjonalnie przekazać również listę custom itemów.
  Future<Either<Failure, void>> shareSelectedItemsWithFriend({
    required String friendUid,
    required List<ShoppingListMealIngredientModel> selected,
    List<ShoppingListCustomItemModel> selectedCustom = const [],
  }) {
    return handleFirestoreFailure(() async {
      final toShareMeals = selected.where((m) => !m.isDeleted).toList();
      final toShareCustom =
          selectedCustom.where((c) => !c.isDeleted).toList();

      await _service.shareShoppingListWithFriend(
        friendUid: friendUid,
        mealItemsToShare: toShareMeals,
        customItemsToShare: toShareCustom,
      );
      return;
    });
  }
}