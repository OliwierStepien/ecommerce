import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/planned_meal/repository/sync/planned_meal_sync_service.dart';
import 'package:mealapp/service_locator.dart';

class ConnectionMonitor {
  final PlannedMealSyncService syncService;
  final Connectivity connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectionMonitor({required this.syncService});

  void startMonitoring() {
    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      if (results.any((result) => result != ConnectivityResult.none)) {
        final isOnline = await sl<NetworkInfo>().checkInternetConnection();
        if (isOnline) {
          debugPrint('[ConnectionMonitor] Internet connection restored - syncing data');
          await syncService.syncData();
        }
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }
}