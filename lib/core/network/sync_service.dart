/// Interfejs dla serwisów, które obsługują synchronizację.
/// Dzięki niemu `ConnectionMonitor` i inne klasy mogą wywołać metodę `syncData()`
/// niezależnie od konkretnej implementacji serwisu.
abstract class SyncService {
  Future<void> syncData();
}