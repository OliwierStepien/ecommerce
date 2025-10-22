import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/usecase/is_logged_in.dart';
import 'package:mealapp/presentation/splash/bloc/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class SplashCubit extends Cubit<SplashState> {
  final ConnectionMonitor connectionMonitor;
  final IsLoggedInUseCase isLoggedInUseCase;

  SplashCubit({
    required this.connectionMonitor,
    required this.isLoggedInUseCase,
  }) : super(const DisplaySplash()) {
    unawaited(start());
  }

  Future<void> start({Duration delay = const Duration(seconds: 2)}) async {
    emit(const DisplaySplash());
    await Future.delayed(delay);
    await _checkAuthStatus();
    connectionMonitor.startMonitoring();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await isLoggedInUseCase(NoParams());
    if (isClosed) return;

    emit(isLoggedIn ? const Authenticated() : const UnAuthenticated());
  }
}
