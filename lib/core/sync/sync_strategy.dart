import 'dart:async';

abstract class SyncStrategy {
  /// Triggered when data changes
  Future<void> onDataChanged();

  /// Triggered when app resumes
  Future<void> onAppResumed();

  /// Triggered when app pauses
  Future<void> onAppPaused();

  /// Triggered when network connection is restored
  Future<void> onNetworkRestored();

  /// Clean up resources
  void dispose();
}

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
    _syncTimer?.cancel();
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