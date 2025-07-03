import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/service_locator.dart';

abstract class SyncService {
  Future<void> syncData();
}

class ConnectionMonitor {
  final List<SyncService> syncServices;
  final Connectivity connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectionMonitor({required this.syncServices});

  void startMonitoring() {
    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      if (results.any((result) => result != ConnectivityResult.none)) {
        final isOnline = await sl<NetworkInfo>().checkInternetConnection();
        if (isOnline) {
          debugPrint('[ConnectionMonitor] Internet connection restored - syncing data');
          for (final service in syncServices) {
            try {
              await service.syncData();
            } catch (e) {
              debugPrint('[ConnectionMonitor] Error during sync: $e');
            }
          }
        }
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }
}