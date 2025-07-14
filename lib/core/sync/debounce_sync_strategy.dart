import 'dart:async';

/// Strategia synchronizacji z opóźnieniem (debounce).
/// Pozwala na ograniczenie liczby wywołań synchronizacji, gdy dane zmieniają się często.
/// Zamiast synchronizować natychmiast, odczekuje określony czas (domyślnie 3 sekundy),
/// a następnie wykonuje `syncCallback`, jeśli nie było kolejnych zmian.
class DebounceSyncStrategy {
  /// Czas opóźnienia przed wywołaniem synchronizacji
  final Duration debounceDuration;

  /// Funkcja odpowiedzialna za wykonanie synchronizacji
  final Future<void> Function() syncCallback;

  /// Timer używany do implementacji debounce
  Timer? _syncTimer;

  /// Konstruktor — ustawia funkcję synchronizacji i opcjonalnie czas opóźnienia
  DebounceSyncStrategy({
    required this.syncCallback,
    this.debounceDuration = const Duration(seconds: 3),
  });

  /// Metoda wywoływana, gdy dane ulegną zmianie.
  /// Anuluje poprzedni timer (jeśli istnieje) i ustawia nowy.
  /// Dzięki temu synchronizacja nie zostanie wykonana, dopóki nie ustanie „szum” zmian.
  Future<void> onDataChanged() async {
    _syncTimer?.cancel();
    _syncTimer = Timer(debounceDuration, () => syncCallback());
  }

  /// Wywoływana, gdy aplikacja zostaje wznowiona (np. powrót z tła).
  /// Wymusza natychmiastową synchronizację.
  Future<void> onAppResumed() => syncCallback();

  /// Wywoływana, gdy aplikacja przechodzi w tło (pauza).
  /// Anuluje timer (jeśli istnieje) i od razu wykonuje synchronizację.
  Future<void> onAppPaused() {
    _syncTimer?.cancel();
    return syncCallback();
  }

  /// Zwalnia zasoby – anuluje aktywny timer, jeśli istnieje.
  void dispose() {
    _syncTimer?.cancel();
  }
}