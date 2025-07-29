import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/mapper/shopping_list_custom_item_mapper.dart';
import 'package:mealapp/data/shopping_list_custom_item/model/shopping_list_custom_item_model.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';

/// 🔄 Synchronizuje niestandardowe elementy listy zakupów między lokalnym Hive a zdalnym Firestore.
/// Proces synchronizacji:
/// 1. Sprawdzenie połączenia z internetem
/// 2. Usunięcie elementów oznaczonych jako `isDeleted`
/// 3. Dodanie lub aktualizacja pozostałych
/// 4. Oznaczenie elementów jako zsynchronizowane (`isSynced`)
class ShoppingListCustomItemSyncService implements SyncService {
  final ShoppingListCustomItemRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  ShoppingListCustomItemSyncService({
    required ShoppingListCustomItemRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> syncData() async {
    // 1) Sprawdź, czy urządzenie ma dostęp do internetu
    if (!await _networkInfo.checkInternetConnection()) {
      // Jeśli brak połączenia, zwróć błąd sieci
      return Left(NetworkFailure());
    }

    // 2) Pobierz lokalne dane z Hive
    final box = Hive.box<ShoppingListCustomItemModel>('shoppingListCustomItems');

    // Filtrujemy tylko te, które jeszcze nie zostały zsynchronizowane
    final unsyncedModels = box.values.where((m) => !m.isSynced);

    // Rozdziel dane na:
    // - Te oznaczone jako usunięte
    final deletedModels = unsyncedModels.where((m) => m.isDeleted).toList();

    // - Te, które mają zostać dodane lub zaktualizowane (ale nie są usunięte)
    final nonDeletedModels = _deduplicate(
      unsyncedModels.where((m) => !m.isDeleted),
    );

    // 3) Synchronizacja usuniętych modeli — usuń je z Firestore
    final deletionFailure = await _syncDeletedModels(deletedModels, box);
    if (deletionFailure != null) {
      // Jeśli wystąpił błąd przy usuwaniu, zakończ synchronizację
      return Left(deletionFailure);
    }

    // 4) Synchronizacja pozostałych — dodanie/aktualizacja w Firestore
    final addFailure = await _syncAdditions(nonDeletedModels, box);
    if (addFailure != null) {
      // Jeśli wystąpił błąd, zwróć go
      return Left(addFailure);
    }

    // Jeśli wszystko się powiodło — zwracamy sukces
    return const Right(null);
  }

  /* ---------- POMOCNICZE METODY ---------- */

  /// 🔑 Zwraca klucz identyfikujący model (customItemId) — używane do Hive box
  String _modelKey(ShoppingListCustomItemModel m) => m.customItemId;

  /// 🔁 Usuwa duplikaty modeli na podstawie customItemId (pozostawia ostatni wpis)
  List<ShoppingListCustomItemModel> _deduplicate(
    Iterable<ShoppingListCustomItemModel> models,
  ) {
    final map = <String, ShoppingListCustomItemModel>{};

    for (final m in models) {
      map[_modelKey(m)] = m; // nadpisuje wcześniejsze wpisy o tym samym ID
    }

    // Zwraca listę unikalnych modeli
    return map.values.toList();
  }

  /// 🗑️ Synchronizuje usuwanie elementów — najpierw usuwa z Firestore, a potem z Hive
  Future<Failure?> _syncDeletedModels(
    List<ShoppingListCustomItemModel> models,
    Box<ShoppingListCustomItemModel> box,
  ) async {
    for (final m in models) {
      // 1) Próba usunięcia z Firestore
      final result =
          await _remoteRepository.removeCustomItemFromShoppingList(m.customItemId);

      // 2) Jeśli nie udało się usunąć z Firestore — przerwij i zwróć błąd
      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      // 3) Po udanym usunięciu — fizycznie usuń z Hive
      await box.delete(_modelKey(m));
    }

    // Wszystko się powiodło
    return null;
  }

  /// ➕ Synchronizuje dodawanie/aktualizację elementów — wysyła do Firestore i oznacza jako zsynchronizowane w Hive
  Future<Failure?> _syncAdditions(
    List<ShoppingListCustomItemModel> models,
    Box<ShoppingListCustomItemModel> box,
  ) async {
    for (final m in models) {
      // 1) Zamiana modelu Hive na encję domenową (potrzebną do zapisu w Firestore)
      final entity = ShoppingListCustomItemMapper.toEntity(m);

      // 2) Próba dodania lub aktualizacji w Firestore
      final result = await _remoteRepository.addCustomItemToShoppingList(entity);

      // 3) Jeśli nie udało się — zakończ i zwróć błąd
      final failure = _failureOrNull(result);
      if (failure != null) return failure;

      // 4) Oznaczenie w Hive jako zsynchronizowany i nieusunięty
      await box.put(
        _modelKey(m),
        m.copyWith(isSynced: true, isDeleted: false),
      );
    }

    // Wszystko się powiodło
    return null;
  }

  /// 🔍 Pomocnicza metoda do wyciągania błędu z Either<Failure, void>
  Failure? _failureOrNull(Either<Failure, void> result) {
    return result.fold(
      (failure) => failure, // jeśli jest Left — zwróć Failure
      (success) => null,          // jeśli jest Right — brak błędu
    );
  }
}