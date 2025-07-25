
import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/remote/firebase_shopping_list_custom_item_service.dart';
import 'package:mealapp/domain/shopping_list_custom_item/entity/shopping_list_custom_item_entity.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// Implementacja repozytorium dla niestandardowych elementów listy zakupów
/// wykorzystująca Firebase jako źródło danych. Łączy warstwę domenową z warstwą infrastruktury.
class FirebaseShoppingListCustomItemRepositoryImpl
    implements ShoppingListCustomItemRepository {
  
  // Prywatne pole przechowujące referencję do serwisu Firebase
  final FirebaseShoppingListCustomItemService _firebaseShoppingListCustomItemService;

  /// Konstruktor przyjmujący wymagany serwis Firebase jako zależność
  /// Umożliwia wstrzykiwanie mocków do testów
  FirebaseShoppingListCustomItemRepositoryImpl(
      {required FirebaseShoppingListCustomItemService
          firebaseShoppingListCustomItemService})
      : _firebaseShoppingListCustomItemService =
            firebaseShoppingListCustomItemService;

  /// Dodaje niestandardowy element do listy zakupów w Firestore
  /// [shoppingListCustomItemEntity] - encja reprezentująca element do dodania
  /// Zwraca Either<Failure, void> - wynik operacji (sukces lub błąd)
  @override
  Future<Either<Failure, void>> addCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity) async {
    // Użycie helpera do obsługi błędów Firestore
    return handleFirestoreFailure(() async {
      // Wywołanie serwisu Firebase po konwersji encji na model
      await _firebaseShoppingListCustomItemService.addCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(
          shoppingListCustomItemEntity,
        ),
      );
    });
  }

  /// Usuwa niestandardowy element z listy zakupów w Firestore
  /// [customItemId] - ID elementu do usunięcia
  /// Zwraca Either<Failure, void> - wynik operacji
  @override
  Future<Either<Failure, void>> removeCustomItemFromShoppingList(
      String customItemId) async {
    return handleFirestoreFailure(() async {
      // Bezpośrednie wywołanie serwisu Firebase z podanym ID
      await _firebaseShoppingListCustomItemService
          .removeCustomItemFromShoppingList(customItemId);
    });
  }

  /// Pobiera wszystkie niestandardowe elementy listy zakupów z Firestore
  /// Zwraca Either<Failure, List<ShoppingListCustomItemEntity>> - listę encji lub błąd
  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getCustomItemToShoppingList() async {
    return handleFirestoreFailure(() async {
      // Pobranie danych z Firestore
      final returnedData = await _firebaseShoppingListCustomItemService
          .getCustomItemFromShoppingList();
      
      // Konwersja listy modeli na listę encji domenowych
      return returnedData.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  /// Pobiera niezsynchronizowane zmiany dla niestandardowych elementów
  /// Obecnie zwraca pustą listę
  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedChangesForShoppingListCustomItem() async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }

  /// Pobiera wszystkie niezsynchronizowane niestandardowe elementy listy zakupów
  /// Zwraca Either<Failure, List<ShoppingListCustomItemEntity>> - listę encji lub błąd
  @override
  Future<Either<Failure, List<ShoppingListCustomItemEntity>>>
      getUnsyncedShoppingListCustomItem() async {
    return handleFirestoreFailure(() async {
      // Pobranie wszystkich elementów (w przyszłości można dodać filtrowanie po isSynced)
      final allMeals = await _firebaseShoppingListCustomItemService
          .getCustomItemFromShoppingList();
          
      // Konwersja na encje domenowe
      return allMeals.map(ShoppingListCustomItemMapper.toEntity).toList();
    });
  }

  /// Oznacza element jako zsynchronizowany
  /// [customItemId] - ID elementu do oznaczenia
  @override
  Future<Either<Failure, void>> markShoppingListCustomItemAsSynced(
      String customItemId) async {
    return handleFirestoreFailure(() async {
      return;
    });
  }

  /// Przywraca usunięty niestandardowy element do listy zakupów
  /// [shoppingListCustomItemEntity] - encja reprezentująca element do przywrócenia
  @override
  Future<Either<Failure, void>> restoreCustomItemToShoppingList(
      ShoppingListCustomItemEntity shoppingListCustomItemEntity) async {
    return handleFirestoreFailure(() async {
      // Wywołanie serwisu Firebase po konwersji encji na model
      await _firebaseShoppingListCustomItemService
          .restoreCustomItemToShoppingList(
        ShoppingListCustomItemMapper.toModel(shoppingListCustomItemEntity),
      );
    });
  }
}