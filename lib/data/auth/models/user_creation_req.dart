class UserCreationReq {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  UserCreationReq({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}
