import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/service_locator.dart';

/// Lekka implementacja z natychmiastowym fallbackiem (jeśli jest connectivity)
/// i asynchroniczną/współdzieloną walidacją realnej dostępności internetu.
class NetworkInfoImpl implements NetworkInfo {
  final Duration _cacheDuration = const Duration(seconds: 5);
  bool _lastResult = false;
  DateTime _lastChecked = DateTime.fromMillisecondsSinceEpoch(0);
  Future<bool>? _ongoingValidation;

  @override
  Future<bool> checkInternetConnection() async {
    final now = DateTime.now();

    // Jeśli cache jest świeży, zwróć go natychmiast.
    if (now.difference(_lastChecked) < _cacheDuration) {
      debugPrint(
          '[NetworkInfoImpl] returning cached internet status: $_lastResult');
      return _lastResult;
    }

    // Sprawdź tylko warstwę connectivity fizycznego (zwykle szybkie).
    final connectivityResult = await sl<Connectivity>().checkConnectivity();
    final hasPhysical =
        connectivityResult.any((result) => result != ConnectivityResult.none);
    debugPrint(
        '[NetworkInfoImpl] connectivity status: $connectivityResult, hasPhysical=$hasPhysical');

    if (!hasPhysical) {
      _lastResult = false;
      _lastChecked = now;
      debugPrint('[NetworkInfoImpl] no physical connection => result=false');
      return false;
    }

    // Jest połączenie fizyczne: zwracamy optymistycznie true, a w tle weryfikujemy realny dostęp.
    _scheduleRealCheck(); // nie awaitujemy - robi się w tle

    return true;
  }

  // Wewnętrzne: robi rzeczywistą weryfikację z de-duplikacją i cache'owaniem.
  void _scheduleRealCheck() {
    if (_ongoingValidation != null) return; // już w toku

    _ongoingValidation = _validateRealConnection().whenComplete(() {
      _ongoingValidation = null;
    });
  }

  Future<bool> _validateRealConnection() async {
    final now = DateTime.now();
    final stopwatchTotal = Stopwatch()..start();

    bool result;
    try {
      final stopwatchReal = Stopwatch()..start();
      result = await sl<InternetConnectionChecker>().hasConnection;
      stopwatchReal.stop();
      if (stopwatchReal.elapsedMilliseconds > 300 || result != _lastResult) {
        debugPrint(
            '[NetworkInfoImpl] real connection check took ${stopwatchReal.elapsedMilliseconds}ms, result=$result');
      }
    } catch (e) {
      result = false;
      debugPrint('[NetworkInfoImpl] real connection check error: $e');
    }

    stopwatchTotal.stop();
    final previous = _lastResult;
    _lastResult = result;
    _lastChecked = now;

    if (result != previous || stopwatchTotal.elapsedMilliseconds > 500) {
      debugPrint(
          '[NetworkInfoImpl] validated real connection = $result, total time ${stopwatchTotal.elapsedMilliseconds}ms');
    }
    return result;
  }
}
