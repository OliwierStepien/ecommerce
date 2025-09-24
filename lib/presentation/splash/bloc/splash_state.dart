import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class DisplaySplash extends SplashState {
  const DisplaySplash();
}

class Authenticated extends SplashState {
  const Authenticated();
}

class UnAuthenticated extends SplashState {
  const UnAuthenticated();
}
