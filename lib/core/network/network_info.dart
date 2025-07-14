import 'package:connectivity_plus/connectivity_plus.dart';

/// Prosty interfejs sprawdzający obecność połączenia sieciowego
class NetworkInfo {
  /// Sprawdza, czy urządzenie ma aktywne połączenie (WiFi lub komórkowe)
  Future<bool> checkInternetConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    // Zwraca true, jeśli jakikolwiek typ połączenia jest dostępny
    return connectivityResults.any((result) => result != ConnectivityResult.none);
  }
}