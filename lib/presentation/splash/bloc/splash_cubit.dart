import 'package:mealapp/domain/auth/usecases/is_logged_in.dart';
import 'package:mealapp/presentation/splash/bloc/splash_state.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(DisplaySplash());

  Future<void> appStarted() async {
    await Future.delayed(const Duration(seconds: 2));
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    final isLoggedIn = await sl<IsLoggedInUseCase>().call();
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }
}