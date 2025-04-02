import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/service_locator.dart';

class NetworkInfoImpl implements NetworkInfo {

  @override
  Future<bool> checkInternetConnection() async {
    final connectivityResults = await sl<Connectivity>().checkConnectivity();
    debugPrint('[NetworkInfo] Connectivity results: $connectivityResults');

    final hasConnection = connectivityResults.any(
      (result) => result != ConnectivityResult.none
    );

    if (!hasConnection) {
      debugPrint('[NetworkInfo] No network connection detected');
      return false;
    }

    final hasRealConnection = await sl<InternetConnectionChecker>().hasConnection;
    debugPrint('[NetworkInfo] Internet available: $hasRealConnection');
    return hasRealConnection;
  }
}