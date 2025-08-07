import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/service_locator.dart';

class ConnectionMonitor {
  final List<SyncService> syncServices;
  final NetworkInfo _networkInfo;
  final Connectivity connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  VoidCallback? _onConnectionRestored;
  bool _isSyncing = false;

  ConnectionMonitor({
    required this.syncServices,
    required NetworkInfo networkInfo,
    Connectivity? connectivity,
  })  : _networkInfo = networkInfo,
        connectivity = connectivity ?? Connectivity();

  set onConnectionRestored(VoidCallback callback) {
    _onConnectionRestored = callback;
  }

  void startMonitoring() {
    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      if (results.any((result) => result != ConnectivityResult.none)) {
        final netCheckStopwatch = Stopwatch()..start();
        final isOnline = await _networkInfo.checkInternetConnection();
        netCheckStopwatch.stop();
        debugPrint(
            '[ConnectionMonitor] network check took ${netCheckStopwatch.elapsedMilliseconds}ms, online=$isOnline');

        if (isOnline) {
          if (_isSyncing) {
            debugPrint('[ConnectionMonitor] sync already in progress, skipping new trigger');
            return;
          }
          _isSyncing = true;
          debugPrint('[ConnectionMonitor] Internet connection restored - triggering strategy');

          // Zamiast manualnego wywoływania wszystkich usług – użyj strategii centralnej
          await sl<SyncStrategy>().onNetworkRestored();

          _onConnectionRestored?.call();
          _isSyncing = false;
        }
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }

  void dispose() {
    stopMonitoring();
  }
}