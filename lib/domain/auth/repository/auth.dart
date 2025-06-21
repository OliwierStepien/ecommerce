import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/data/auth/model/user_creation_req.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> signup(UserCreationReq user);
  Future<Either<Failure, String>> signin(UserSigninReq user);
  Future<Either<Failure, String>> sendPasswordResetEmail(String email);
  Future<Either<Failure, String>> signout();
  Future<bool> isLoggedIn();
  Future<Either<Failure, UserEntity>> getUser();
}