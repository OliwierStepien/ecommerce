// presentation/planned_meal_share/bloc/meal_share_state.dart
import 'package:equatable/equatable.dart';

sealed class MealShareState extends Equatable {
  const MealShareState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy / bezczynny
class MealShareIdle extends MealShareState {
  const MealShareIdle();
}

/// W trakcie udostępniania
class MealShareLoading extends MealShareState {
  const MealShareLoading();
}

/// Udało się – możesz pokazać SnackBar z message
class MealShareSuccess extends MealShareState {
  final String message;
  const MealShareSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Błąd – pokaż SnackBar z message
class MealShareFailure extends MealShareState {
  final String message;
  const MealShareFailure(this.message);

  @override
  List<Object?> get props => [message];
}