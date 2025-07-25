
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';

// Interfejs (abstrakcja) definiujący kontrakt dla serwisu obsługującego custom itemy w liście zakupów.
// Ułatwia testowanie oraz zamianę implementacji (np. na lokalną bazę lub mock).
abstract class FirebaseShoppingListCustomItemService {
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item);
  Future<void> removeCustomItemFromShoppingList(String customItemId);
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList();
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item);
}

// Implementacja interfejsu - korzysta z Firebase Firestore oraz Firebase Auth.
class FirebaseShoppingListCustomItemServiceImpl implements FirebaseShoppingListCustomItemService {
  final FirebaseFirestore _firestore; // Instancja Firestore do operacji na bazie.
  final FirebaseAuth _auth;           // Instancja Auth - do identyfikacji aktualnego użytkownika.

  // Konstruktor z opcjonalnym wstrzykiwaniem zależności (np. w testach).
  FirebaseShoppingListCustomItemServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Prywatna metoda pomocnicza - zwraca referencję do kolekcji CustomItems użytkownika.
  // Dzięki temu wszystkie operacje trafiają do odpowiedniego miejsca w strukturze Firestore.
  CollectionReference<Map<String, dynamic>> _userCustomItemsCollection() {
    final user = _auth.currentUser;

    // Jeśli użytkownik nie jest zalogowany - rzucamy wyjątek.
    if (user == null) throw UnauthorizedException();

    // Zwracamy referencję do: Users/{uid}/CustomItems
    return _firestore.collection('Users').doc(user.uid).collection('CustomItems');
  }

  // Dodaje nowy własny produkt do listy zakupów.
  // Dane są zapisywane w dokumencie o ID `customItemId`.
  @override
  Future<void> addCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    return handleFirestoreException(() async {
      await _userCustomItemsCollection()
          .doc(item.customItemId)
          .set(item.toMap()) // Konwersja modelu do mapy (format Firestore).
          .timeout(const Duration(seconds: 15)); // Dodajemy timeout na operację.
    });
  }

  // Usuwa produkt z listy zakupów na podstawie ID.
  @override
  Future<void> removeCustomItemFromShoppingList(String customItemId) async {
    return handleFirestoreException(() async {
      await _userCustomItemsCollection()
          .doc(customItemId)
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  // Pobiera wszystkie produkty z listy zakupów użytkownika, które nie zostały oznaczone jako usunięte.
  @override
  Future<List<ShoppingListCustomItemModel>> getCustomItemFromShoppingList() async {
    return handleFirestoreException(() async {
      final result = await _userCustomItemsCollection()
          .where('isDeleted', isEqualTo: false) // Pobieramy tylko aktywne itemy.
          .get()
          .timeout(const Duration(seconds: 15));

      // Konwertujemy każdy dokument z Firestore na model aplikacji.
      return result.docs.map((doc) => ShoppingListCustomItemModel.fromMap(doc.data())).toList();
    });
  }

  // Przywraca produkt na listę zakupów (np. po cofnięciu usunięcia).
  @override
  Future<void> restoreCustomItemToShoppingList(ShoppingListCustomItemModel item) async {
    // Używamy tej samej logiki co przy dodawaniu (nadpisanie dokumentu).
    return addCustomItemToShoppingList(item);
  }
}