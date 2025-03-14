class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String? ?? "",
      firstName: map['firstName'] as String? ?? "",
      lastName: map['lastName'] as String? ?? "",
      email: map['email'] as String? ?? "",
    );
  }
}
