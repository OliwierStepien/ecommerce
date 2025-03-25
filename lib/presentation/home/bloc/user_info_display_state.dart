import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/auth/entity/user.dart';

abstract class UserInfoDisplayState extends Equatable {}

class UserInfoLoading extends UserInfoDisplayState {
  @override
  List<Object?> get props => [];
}

class UserInfoLoaded extends UserInfoDisplayState {
  final UserEntity user;

  UserInfoLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoadUserInfoFailure extends UserInfoDisplayState {
  final String message;

  LoadUserInfoFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
