import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';

sealed class UserInfoDisplayState extends Equatable {
  const UserInfoDisplayState();

  @override
  List<Object?> get props => [];
}

class UserInfoLoading extends UserInfoDisplayState {
  const UserInfoLoading();
}

class UserInfoLoaded extends UserInfoDisplayState {
  final UserEntity user;

  const UserInfoLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoadUserInfoFailure extends UserInfoDisplayState {
  final String message;

  const LoadUserInfoFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
