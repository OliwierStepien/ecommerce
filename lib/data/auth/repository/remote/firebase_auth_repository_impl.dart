import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/auth/mapper/user_mapper.dart';
import 'package:mealapp/data/auth/model/user_model.dart';
import 'package:mealapp/data/auth/model/user_creation_req.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:mealapp/data/auth/source/remote/firebase_auth_service.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class FirebaseAuthRepositoryImpl extends AuthRepository {
  final FirebaseAuthService _firebaseAuthService;

  FirebaseAuthRepositoryImpl({required FirebaseAuthService firebaseAuthService})
      : _firebaseAuthService = firebaseAuthService;

  @override
  Future<Either<Failure, String>> signup(UserCreationReq user) async {
    return handleFirestoreFailure(() async {
      return await _firebaseAuthService.signup(user);
    });
  }

  @override
  Future<Either<Failure, String>> signin(UserSigninReq user) async {
    return handleFirestoreFailure(() async {
      final message = await _firebaseAuthService.signin(user);
      return message;
    });
  }

  @override
  Future<Either<Failure, String>> sendPasswordResetEmail(String email) async {
    return handleFirestoreFailure(() async {
      return await _firebaseAuthService.sendPasswordResetEmail(email);
    });
  }

  @override
  Future<Either<Failure, String>> signout() async {
    return handleFirestoreFailure(() async {
      final message = await _firebaseAuthService.signout();
      return message;
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    return _firebaseAuthService.isLoggedIn();
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    return handleFirestoreFailure(() async {
      final user = await _firebaseAuthService.getUser();
      return UserMapper.toEntity(UserModel.fromMap(user));
    });
  }
}
