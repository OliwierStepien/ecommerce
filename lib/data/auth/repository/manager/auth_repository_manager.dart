import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/auth/model/user_creation_req.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:mealapp/data/auth/repository/local/hive_auth_repository_impl.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class AuthRepositoryManager extends AuthRepository {
  final AuthRepository _remoteRepository;
  final NetworkInfo _networkInfo;

  AuthRepositoryManager({
    required AuthRepository remoteRepository,
    required NetworkInfo networkInfo,
  })  : _remoteRepository = remoteRepository,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, String>> signup(UserCreationReq user) async {
    debugLog('[AUTH_MANAGER] signup for ${user.email}');
    final isOnline = await _networkInfo.checkInternetConnection();

    if (!isOnline) {
      debugLog('[AUTH_MANAGER] signup -> offline');
      return left(NetworkFailure());
    }

    return await _remoteRepository.signup(user);
  }

  @override
  Future<Either<Failure, String>> signin(UserSigninReq user) async {
    debugLog('[AUTH_MANAGER] signin started for ${user.email}');
    final isOnline = await _networkInfo.checkInternetConnection();

    if (!isOnline) {
      debugLog('[AUTH_MANAGER] signin -> offline, using Hive fallback');
      final localResult = await sl<HiveAuthRepositoryImpl>().getLoggedInUser();
      return localResult.fold(
        (failure) {
          debugLog('[AUTH_MANAGER] Hive fallback failed');
          return left(NetworkFailure());
        },
        (userEntity) {
          debugLog('[AUTH_MANAGER] Hive fallback success for ${userEntity.email}');
          return right('Logowanie zakończone sukcesem');
        },
      );
    }

    final result = await _remoteRepository.signin(user);

    if (result.isRight()) {
      debugLog('[AUTH_MANAGER] remote signin success, fetching user...');
      final userResult = await _remoteRepository.getUser();
      await userResult.fold(
        (failure) async {
          debugLog('[AUTH_MANAGER] getUser() after signin failed: $failure');
        },
        (userEntity) async {
          debugLog('[AUTH_MANAGER] fetched user ${userEntity.email}, saving to Hive...');
          await sl<HiveAuthRepositoryImpl>().saveLoggedInUser(userEntity);
          debugLog('[AUTH_MANAGER] user saved to Hive.');
        },
      );
    } else {
      debugLog('[AUTH_MANAGER] remote signin failed');
    }

    return result;
  }

  @override
  Future<Either<Failure, String>> sendPasswordResetEmail(String email) async {
    debugLog('[AUTH_MANAGER] sendPasswordResetEmail for $email');
    final isOnline = await _networkInfo.checkInternetConnection();

    if (!isOnline) {
      return left(NetworkFailure());
    }

    return await _remoteRepository.sendPasswordResetEmail(email);
  }

  @override
  Future<Either<Failure, String>> signout() async {
    debugLog('[AUTH_MANAGER] signout started...');
    await sl<HiveAuthRepositoryImpl>().logout();

    final isOnline = await _networkInfo.checkInternetConnection();
    if (isOnline) {
      debugLog('[AUTH_MANAGER] signout -> remote signout');
      return await _remoteRepository.signout();
    } else {
      debugLog('[AUTH_MANAGER] signout -> offline, local only');
      return right('Wylogowano lokalnie');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final isOnline = await _networkInfo.checkInternetConnection();
    debugLog('[AUTH_MANAGER] checking login status (online=$isOnline)');

    if (isOnline) {
      final loggedIn = await _remoteRepository.isLoggedIn();
      debugLog('[AUTH_MANAGER] Firebase loggedIn=$loggedIn');
      return loggedIn;
    } else {
      final result = await sl<HiveAuthRepositoryImpl>().getLoggedInUser();
      final localLogged = result.isRight();
      debugLog('[AUTH_MANAGER] Hive loggedIn=$localLogged');
      return localLogged;
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    final isOnline = await _networkInfo.checkInternetConnection();
    debugLog('[AUTH_MANAGER] getUser (online=$isOnline)');

    if (isOnline) {
      final result = await _remoteRepository.getUser();
      await result.fold(
        (failure) async {
          debugLog('[AUTH_MANAGER] getUser failed (remote): $failure');
        },
        (user) async {
          debugLog('[AUTH_MANAGER] got remote user ${user.email}, saving to Hive...');
          await sl<HiveAuthRepositoryImpl>().saveLoggedInUser(user);
        },
      );
      return result;
    } else {
      debugLog('[AUTH_MANAGER] offline, loading user from Hive...');
      final localUser = await sl<HiveAuthRepositoryImpl>().getLoggedInUser();
      localUser.fold(
        (failure) => debugLog('[AUTH_MANAGER] Hive user fetch failed: $failure'),
        (user) => debugLog('[AUTH_MANAGER] Hive user loaded: ${user.email}'),
      );
      return localUser;
    }
  }
}