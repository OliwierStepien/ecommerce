// core/diagnostics/startup_planned_meal_logger.dart
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/service_locator.dart';

class StartupPlannedMealLogger {
  /// Odpala dwa zapytania: do Hive i do Firebase — tylko po to,
  /// żeby wypisać liczbę posiłków w terminalu po starcie aplikacji.
  static Future<void> logOnStartup() async {
    debugLog('🔎 Startup metrics: PlannedMeals — collecting...', name: 'Startup');

    // HIVE
    try {
      final hiveRepo = sl<HivePlannedMealRepositoryImpl>();
      final hiveRes = await hiveRepo.getPlannedMeals();
      hiveRes.fold(
        (f) => debugLog('❌ Hive count failed: ${f.runtimeType}', name: 'Startup'),
        (list) => debugLog('📦 Hive PlannedMeals count: ${list.length}', name: 'Startup'),
      );
    } catch (e) {
      debugLog('❌ Hive count exception: $e', name: 'Startup');
    }

    // FIREBASE
    try {
      final firebaseRepo = sl<FirebasePlannedMealRepositoryImpl>();
      final fbRes = await firebaseRepo.getPlannedMeals();
      fbRes.fold(
        (f) => debugLog('❌ Firebase count failed: ${f.runtimeType}', name: 'Startup'),
        (list) => debugLog('☁️ Firebase PlannedMeals count: ${list.length}', name: 'Startup'),
      );
    } catch (e) {
      debugLog('❌ Firebase count exception: $e', name: 'Startup');
    }

    debugLog('✅ Startup metrics: PlannedMeals — done.', name: 'Startup');
  }
}