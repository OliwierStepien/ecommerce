import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/storage/hive_init.dart';
import 'package:mealapp/firebase_options.dart';
import 'package:mealapp/my_app_wrapper.dart';
import 'package:mealapp/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Czcionki (Playfair Display + DM Sans) są dołączone w assets/google_fonts/
  // — nie pobieraj ich z sieci.
  GoogleFonts.config.allowRuntimeFetching = false;
  await HiveConfig.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();

  runApp(const MyAppWrapper());
}