import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/service_locator.dart';

/// Rozszerzona implementacja NetworkInfo, która oprócz typu połączenia
/// sprawdza również rzeczywisty dostęp do internetu.
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> checkInternetConnection() async {
    // Sprawdzenie czy urządzenie ma aktywne połączenie (WiFi, Mobile)
    final connectivityResults = await sl<Connectivity>().checkConnectivity();
    debugPrint('[NetworkInfo] Connectivity results: $connectivityResults');

    final hasConnection = connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      debugPrint('[NetworkInfo] No network connection detected');
      return false;
    }

    // Dodatkowa weryfikacja, czy faktycznie można połączyć się z internetem
    final hasRealConnection = await sl<InternetConnectionChecker>().hasConnection;
    debugPrint('[NetworkInfo] Internet available: $hasRealConnection');

    return hasRealConnection;
  }
}