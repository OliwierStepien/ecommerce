class UserModel {
  final String userId;
  final String firstName;
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
