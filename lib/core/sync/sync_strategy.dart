import 'dart:async';

/// Interfejs strategii synchronizacji.
/// Pozwala na stworzenie różnych implementacji obsługi synchronizacji
/// np. opóźnionej (debounce), natychmiastowej, okresowej itp.
abstract class SyncStrategy {
  Future<void> onDataChanged();       // dane uległy zmianie
  Future<void> onAppResumed();        // aplikacja wznowiona
  Future<void> onAppPaused();         // aplikacja zminimalizowana
  Future<void> onNetworkRestored();   // przywrócono internet
  void dispose();                     // czyszczenie zasobów
}

/// Implementacja strategii debounce:
/// opóźnia synchronizację, dopóki zmiany nie ustabilizują się na określony czas
class DebounceSyncStrategy implements SyncStrategy {
  final Future<void> Function() syncCallback;
  final Duration debounceDuration;
  Timer? _syncTimer;

  DebounceSyncStrategy({
    required this.syncCallback,
    this.debounceDuration = const Duration(seconds: 3),
  });

  @override
  Future<void> onDataChanged() async {
    _syncTimer?.cancel(); // Anuluj poprzednie wywołanie
    _syncTimer = Timer(debounceDuration, () => syncCallback());
  }

  @override
  Future<void> onAppResumed() async {
    _syncTimer?.cancel();
    await syncCallback();
  }

  @override
  Future<void> onAppPaused() async {
    _syncTimer?.cancel();
    await syncCallback();
  }

  @override
  Future<void> onNetworkRestored() async {
    _syncTimer?.cancel();
    await syncCallback();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
  }
}