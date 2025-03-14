import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;

  const UserEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });
  
  @override
  List<Object> get props => [userId, firstName, lastName, email];
}
