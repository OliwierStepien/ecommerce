import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/auth/model/user_creation_req.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:mealapp/data/auth/repository/local/hive_auth_repository_impl.dart';
import 'package:mealapp/data/auth/repository/remote/firebase_auth_repository_impl.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class NetworkAwareAuthRepository extends AuthRepository {
  @override
  Future<Either<Failure, String>> signup(UserCreationReq user) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();

    if (!isOnline) {
      return left(NetworkFailure());
    }

    return await sl<FirebaseAuthRepositoryImpl>().signup(user);
  }

  @override
  Future<Either<Failure, String>> signin(UserSigninReq user) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();

    if (isOnline) {
      final result = await sl<FirebaseAuthRepositoryImpl>().signin(user);

      result.fold(
        (failure) {},
        (_) async {
          final userResult = await sl<FirebaseAuthRepositoryImpl>().getUser();
          userResult.fold(
            (failure) {},
            (userEntity) async {
              await sl<HiveAuthRepositoryImpl>().saveLoggedInUser(userEntity);
            },
          );
        },
      );

      return result;
    } else {
      final localResult = await sl<HiveAuthRepositoryImpl>().getLoggedInUser();
      return localResult.fold(
        (failure) => left(NetworkFailure()),
        (user) => right('Logowanie zakończone sukcesem'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> sendPasswordResetEmail(String email) async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();

    if (!isOnline) {
      return left(NetworkFailure());
    }

    return await sl<FirebaseAuthRepositoryImpl>().sendPasswordResetEmail(email);
  }

  @override
  Future<Either<Failure, String>> signout() async {
    await sl<HiveAuthRepositoryImpl>().logout();

    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    if (isOnline) {
      return await sl<FirebaseAuthRepositoryImpl>().signout();
    } else {
      return right('Wylogowano lokalnie');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    if (isOnline) {
      return await sl<FirebaseAuthRepositoryImpl>().isLoggedIn();
    } else {
      final result = await sl<HiveAuthRepositoryImpl>().getLoggedInUser();
      return result.isRight();
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();

    if (isOnline) {
      final result = await sl<FirebaseAuthRepositoryImpl>().getUser();
      result.fold(
        (failure) {},
        (user) async {
          await sl<HiveAuthRepositoryImpl>().saveLoggedInUser(user);
        },
      );
      return result;
    } else {
      return await sl<HiveAuthRepositoryImpl>().getLoggedInUser();
    }
  }
}