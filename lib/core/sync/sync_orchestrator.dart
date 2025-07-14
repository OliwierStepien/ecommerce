
import 'package:flutter/foundation.dart';
import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';

class SyncOrchestrator {
  final ConnectionMonitor _connectionMonitor;
  final SyncStrategy _syncStrategy;
  final List<VoidCallback> _syncListeners = [];

  SyncOrchestrator({
    required ConnectionMonitor connectionMonitor,
    required SyncStrategy syncStrategy,
  })  : _connectionMonitor = connectionMonitor,
        _syncStrategy = syncStrategy {
    _connectionMonitor.onConnectionRestored = _handleConnectionRestored;
  }

  void _handleConnectionRestored() {
    triggerSync();
  }

  void addSyncListener(VoidCallback listener) {
    _syncListeners.add(listener);
  }

  void removeSyncListener(VoidCallback listener) {
    _syncListeners.remove(listener);
  }

  Future<void> triggerSync() async {
    try {
      await _syncStrategy.onDataChanged();
      _notifyListeners();
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  void _notifyListeners() {
    for (final listener in _syncListeners) {
      listener();
    }
  }

  Future<void> initialize() async {
    _connectionMonitor.startMonitoring();
    await triggerSync();
  }

  void dispose() {
    _connectionMonitor.stopMonitoring();
    _syncListeners.clear();
    _syncStrategy.dispose();
  }
}