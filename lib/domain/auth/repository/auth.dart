import 'package:dartz/dartz.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';

abstract class AuthRepository {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> sendPasswordResetEmail(String email);
  Future<Either> signout();
  Future<bool> isLoggedIn();
  Future<Either> getUser();
}
