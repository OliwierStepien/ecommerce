import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/auth/mapper/user_mapper.dart';
import 'package:mealapp/data/auth/models/user.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/data/auth/source/auth_firebase_service.dart';
import 'package:mealapp/domain/auth/entity/user.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<Failure, String>> signup(UserCreationReq user) async {
    return handleFirestoreFailure(() async {
      return await sl<AuthFirebaseService>().signup(user);
    });
  }

  @override
  Future<Either<Failure, String>> signin(UserSigninReq user) async {
    return handleFirestoreFailure(() async {
      final message = await sl<AuthFirebaseService>().signin(user);
      return message;
    });
  }

  @override
  Future<Either<Failure, String>> sendPasswordResetEmail(String email) async {
    return handleFirestoreFailure(() async {
      return await sl<AuthFirebaseService>().sendPasswordResetEmail(email);
    });
  }

  @override
  Future<Either<Failure, String>> signout() async {
    return handleFirestoreFailure(() async {
      final message = await sl<AuthFirebaseService>().signout();
      return message;
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    return sl<AuthFirebaseService>().isLoggedIn();
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    return handleFirestoreFailure(() async {
      final user = await sl<AuthFirebaseService>().getUser();
      return UserMapper.toEntity(UserModel.fromMap(user));
    });
  }
}
