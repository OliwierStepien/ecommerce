import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';

/// Klasa odpowiedzialna za monitorowanie stanu połączenia sieciowego
/// i automatyczne wywoływanie synchronizacji danych w przypadku jego przywrócenia.
class ConnectionMonitor {
  final List<SyncService> syncServices; // Lista serwisów do synchronizacji
  final NetworkInfo _networkInfo; // Dostawca informacji o połączeniu
  final Connectivity connectivity; // Dostęp do statusu połączenia sieciowego
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  VoidCallback? _onConnectionRestored;

  ConnectionMonitor({
    required this.syncServices, 
    required NetworkInfo networkInfo,
    Connectivity? connectivity,
  })  : _networkInfo = networkInfo,
        connectivity = connectivity ?? Connectivity() {
    startMonitoring();
  }

  /// Ustawienie callbacka uruchamianego po przywróceniu połączenia
  set onConnectionRestored(VoidCallback callback) {
    _onConnectionRestored = callback;
  }

  /// Rozpoczyna nasłuchiwanie zmian połączenia sieciowego
  void startMonitoring() {
    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      if (results.any((result) => result != ConnectivityResult.none)) {
        final isOnline = await _networkInfo.checkInternetConnection();
        if (isOnline) {
          debugPrint('[ConnectionMonitor] Internet connection restored - syncing data');

          // Wywołaj synchronizację dla wszystkich usług
          for (final service in syncServices) {
            try {
              await service.syncData();
            } catch (e) {
              debugPrint('[ConnectionMonitor] Error during sync: $e');
            }
          }

          // Wywołanie zarejestrowanego callbacka (jeśli istnieje)
          _onConnectionRestored?.call();
        }
      }
    });
  }

  /// Zatrzymuje nasłuchiwanie zmian sieci
  void stopMonitoring() {
    _subscription?.cancel();
  }

  /// Zwalnia zasoby
  void dispose() {
    stopMonitoring();
  }
}