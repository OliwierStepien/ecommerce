import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';

class ConnectionMonitor {
  final List<SyncService> syncServices;
  final NetworkInfo _networkInfo;
  final Connectivity connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  VoidCallback? _onConnectionRestored; // Dodane nowe pole

  ConnectionMonitor({
    required this.syncServices, 
    required NetworkInfo networkInfo,
    Connectivity? connectivity, // Dodany opcjonalny parametr
  }) : _networkInfo = networkInfo,
       connectivity = connectivity ?? Connectivity() {
    startMonitoring();
  }

  // Dodany setter dla callbacka
  set onConnectionRestored(VoidCallback callback) {
    _onConnectionRestored = callback;
  }

  void startMonitoring() {
    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      if (results.any((result) => result != ConnectivityResult.none)) {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (isOnline) {
          debugPrint('[ConnectionMonitor] Internet connection restored - syncing data');
          
          // Wywołanie istniejącej logiki
          for (final service in syncServices) {
            try {
              await service.syncData();
            } catch (e) {
              debugPrint('[ConnectionMonitor] Error during sync: $e');
            }
          }
          
          // Wywołanie nowego callbacka jeśli istnieje
          _onConnectionRestored?.call();
        }
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }

  // Zachowaj kompatybilność wsteczną
  void dispose() {
    stopMonitoring();
  }
}