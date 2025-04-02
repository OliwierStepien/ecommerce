import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  Future<bool> checkInternetConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    return connectivityResults.any((result) => result != ConnectivityResult.none);
  }
}