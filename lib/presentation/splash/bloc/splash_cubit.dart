import 'package:flutter/foundation.dart';
import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/domain/auth/usecase/is_logged_in.dart';
import 'package:mealapp/presentation/splash/bloc/splash_state.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(DisplaySplash()) {
    // Odpalamy flow po konstrukcji (nie blokując synchronicznie)
    _init();
  }

  Future<void> _init() async {
    await appStarted();
  }

  Future<void> appStarted() async {
    debugPrint('[SplashCubit] appStarted invoked');
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('[SplashCubit] checking auth status');
    await checkAuthStatus();

    debugPrint('[SplashCubit] auth check done, starting connection monitor');
    sl<ConnectionMonitor>().startMonitoring();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await sl<IsLoggedInUseCase>().call();
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }
}