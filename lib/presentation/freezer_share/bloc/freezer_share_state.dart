import 'package:equatable/equatable.dart';

sealed class FreezerShareState extends Equatable {
  const FreezerShareState();

  @override
  List<Object?> get props => [];
}

class FreezerShareIdle extends FreezerShareState {
  const FreezerShareIdle();
}

class FreezerShareLoading extends FreezerShareState {
  const FreezerShareLoading();
}

class FreezerShareSuccess extends FreezerShareState {
  final String message;
  const FreezerShareSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FreezerShareFailure extends FreezerShareState {
  final String message;
  const FreezerShareFailure(this.message);

  @override
  List<Object?> get props => [message];
}