import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String email;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String? ?? "",
      firstName: map['firstName'] as String? ?? "",
      email: map['email'] as String? ?? "",
    );
  }
}
