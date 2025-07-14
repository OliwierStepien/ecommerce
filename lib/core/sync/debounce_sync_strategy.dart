import 'dart:async';

class DebounceSyncStrategy {
  final Duration debounceDuration;
  final Future<void> Function() syncCallback;
  Timer? _syncTimer;

  DebounceSyncStrategy({
    required this.syncCallback,
    this.debounceDuration = const Duration(seconds: 3),
  });

  Future<void> onDataChanged() async {
    _syncTimer?.cancel();
    _syncTimer = Timer(debounceDuration, () => syncCallback());
  }

  Future<void> onAppResumed() => syncCallback();

  Future<void> onAppPaused() {
    _syncTimer?.cancel();
    return syncCallback();
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}