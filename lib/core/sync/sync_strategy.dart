import 'dart:async';

import 'package:flutter/material.dart';

/// Interfejs strategii synchronizacji.
abstract class SyncStrategy {
  Future<void> onDataChanged(); // dane uległy zmianie
  Future<void> onAppResumed(); // aplikacja wznowiona
  Future<void> onAppPaused(); // aplikacja zminimalizowana
  Future<void> onNetworkRestored(); // przywrócono internet
  void dispose(); // czyszczenie zasobów
}

/// Prosta debounce’owa strategia: opóźnia synchronizację, żeby zgrupować szybkie
/// zmiany w jednym wywołaniu. W przypadku restore/pausa/resume robi natychmiast.
class DebounceSyncStrategy implements SyncStrategy {
  final Future<void> Function() syncCallback;
  final Duration debounceDuration;
  Timer? _syncTimer;
  DateTime? _lastImmediateSync;

  DebounceSyncStrategy({
    required this.syncCallback,
    this.debounceDuration = const Duration(seconds: 3),
  });

  void _scheduleCallback(String reason) {
    debugPrint('[DebounceSyncStrategy] scheduling sync (reason: $reason), debounce=${debounceDuration.inMilliseconds}ms');
    _syncTimer?.cancel();
    _syncTimer = Timer(debounceDuration, () async {
      debugPrint('[DebounceSyncStrategy] debounce period elapsed, executing syncCallback');
      final execStopwatch = Stopwatch()..start();
      try {
        await syncCallback();
      } catch (e) {
        debugPrint('[DebounceSyncStrategy] syncCallback error: $e');
      } finally {
        execStopwatch.stop();
        debugPrint('[DebounceSyncStrategy] syncCallback took ${execStopwatch.elapsedMilliseconds}ms');
      }
    });
  }

  @override
  Future<void> onDataChanged() async {
    _scheduleCallback('onDataChanged');
  }

  @override
  Future<void> onAppResumed() async {
    _syncTimer?.cancel();
    debugPrint('[DebounceSyncStrategy] onAppResumed: immediate sync');
    final execStopwatch = Stopwatch()..start();
    await syncCallback();
    execStopwatch.stop();
    debugPrint('[DebounceSyncStrategy] onAppResumed sync took ${execStopwatch.elapsedMilliseconds}ms');
  }

  @override
  Future<void> onAppPaused() async {
    _syncTimer?.cancel();
    debugPrint('[DebounceSyncStrategy] onAppPaused: immediate sync');
    final execStopwatch = Stopwatch()..start();
    await syncCallback();
    execStopwatch.stop();
    debugPrint('[DebounceSyncStrategy] onAppPaused sync took ${execStopwatch.elapsedMilliseconds}ms');
  }

  @override
  Future<void> onNetworkRestored() async {
    _syncTimer?.cancel();
    // Optional guard to avoid spamming restore syncs:
    if (_lastImmediateSync != null &&
        DateTime.now().difference(_lastImmediateSync!) < const Duration(seconds: 5)) {
      debugPrint('[DebounceSyncStrategy] onNetworkRestored: skipped duplicate immediate sync');
      return;
    }
    _lastImmediateSync = DateTime.now();

    debugPrint('[DebounceSyncStrategy] onNetworkRestored: immediate sync');
    final execStopwatch = Stopwatch()..start();
    await syncCallback();
    execStopwatch.stop();
    debugPrint('[DebounceSyncStrategy] onNetworkRestored sync took ${execStopwatch.elapsedMilliseconds}ms');
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
  }
}