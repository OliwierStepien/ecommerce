// data/shopping_list_clear/repository/firebase_shopping_list_clear_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/shopping_list_clear/source/remote/firebase_shopping_list_clear_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/domain/shopping_list_clear/repository/shopping_list_clear_repository.dart';

/// Repo: "Wyczyść całą listę zakupów"
/// - Zawsze: czyścimy lokalny cache/UI (żeby od razu było pusto)
/// - Online: dodatkowo batch delete w Firestore (oba zbiory)
/// - Offline: lokalnie oznaczamy jako isDeleted=true, isSynced=false (dla sync service)
class FirebaseShoppingListClearRepositoryImpl
    implements ShoppingListClearRepository {
  final FirebaseShoppingListClearService _service;
  final NetworkInfo _networkInfo;
  final HiveShoppingListMealIngredientService _mealHive;
  final HiveShoppingListCustomItemService _customHive;
  final FirebaseAuth _auth;

  FirebaseShoppingListClearRepositoryImpl({
    required FirebaseShoppingListClearService service,
    required NetworkInfo networkInfo,
    required HiveShoppingListMealIngredientService mealHive,
    required HiveShoppingListCustomItemService customHive,
    FirebaseAuth? auth,
  })  : _service = service,
        _networkInfo = networkInfo,
        _mealHive = mealHive,
        _customHive = customHive,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, void>> clearAll() {
    return handleFirestoreFailure(() async {
      final isOnline = await _networkInfo.checkInternetConnection();

      // 1) Zawsze czyścimy lokalnie (UI od razu puste).
      //    Offline -> oznacz do sync, Online -> też oznacz do sync (bezpieczne).
      await _markLocalAsDeletedForSync();

      // 2) Jeśli online — batch delete w Firestore (oba zbiory)
      if (isOnline) {
        await _service.clearAllForCurrentUser();
      }

      return;
    });
  }

  /// Oznacza wszystkie moje wpisy (meal + custom) jako usunięte lokalnie,
  /// aby SyncService mógł je wypchnąć (albo żeby UI natychmiast było puste).
  Future<void> _markLocalAsDeletedForSync() async {
    // --- Meal ingredients ---
    // getMealIngredientFromShoppingList() zwraca już aktywne (!isDeleted) i "mine"
    final allMeals = await _mealHive.getMealIngredientFromShoppingList();
    final toDeleteMeals = allMeals.where((m) => !m.isDeleted).toList();

    for (final m in toDeleteMeals) {
      // remove w serwisie: isOnline=false -> oznacza isDeleted=true, isSynced=false
      await _mealHive.removeMealIngredientFromShoppingList(
        m.copyWith(ownerUid: _uid),
        isOnline: false,
      );
    }

    // --- Custom items ---
    final allCustom = await _customHive.getCustomItemFromShoppingList();
    final toDeleteCustom = allCustom.where((c) => !c.isDeleted).toList();

    for (final c in toDeleteCustom) {
      await _customHive.removeCustomItemFromShoppingList(
        c.customItemId,
        isOnline: false,
      );
    }
  }
}