import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/storage/hive_init.dart';
import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/sync/planned_meal_sync_service.dart';
import 'package:mealapp/firebase_options.dart';
import 'package:mealapp/service_locator.dart';
import 'package:mealapp/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();

  // Initialize sync service and connection monitor
  final syncService = PlannedMealSyncService(
    firebaseRepo: sl<FirebasePlannedMealRepositoryImpl>(),
    hiveRepo: sl<HivePlannedMealRepositoryImpl>(),
    networkInfo: sl<NetworkInfo>(),
  );
  
  final connectionMonitor = ConnectionMonitor(syncService: syncService);
  connectionMonitor.startMonitoring();
  
  // Register in service locator
  sl.registerSingleton(syncService);
  sl.registerSingleton(connectionMonitor);

  runApp(const MyApp());
}