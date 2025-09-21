import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mealapp/core/storage/hive_init.dart';
import 'package:mealapp/firebase_options.dart';
import 'package:mealapp/my_app_wrapper.dart';
import 'package:mealapp/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();

  runApp(const MyAppWrapper());
}