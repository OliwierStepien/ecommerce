import 'package:dartz/dartz.dart';
import 'package:mealapp/data/auth/mapper/user_mapper.dart';
import 'package:mealapp/data/auth/models/user.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/data/auth/source/auth_firebase_service.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signup(UserCreationReq user) async {
    return sl<AuthFirebaseService>().signup(user);
  }

  @override
  Future<Either> signin(UserSigninReq user) {
    return sl<AuthFirebaseService>().signin(user);
  }

  @override
  Future<Either> sendPasswordResetEmail(String email) async {
    return sl<AuthFirebaseService>().sendPasswordResetEmail(email);
  }

  @override
  Future<Either> signout() async {
    return sl<AuthFirebaseService>().signout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return sl<AuthFirebaseService>().isLoggedIn();
  }

  @override
  Future<Either> getUser() async {
    final user = await sl<AuthFirebaseService>().getUser();
    return user.fold(
      (error) {
        return Left(error);
      },
      (data) {
        return Right(
          UserMapper.toEntity(UserModel.fromMap(data)),
        );
      },
    );
  }
}