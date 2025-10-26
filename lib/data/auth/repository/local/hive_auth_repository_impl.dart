import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/auth/source/local/hive_auth_service.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/data/auth/mapper/user_mapper.dart';

class HiveAuthRepositoryImpl {
  final HiveAuthService _hiveAuthService;

  HiveAuthRepositoryImpl({required HiveAuthService hiveAuthService})
      : _hiveAuthService = hiveAuthService;

  Future<Either<Failure, UserEntity>> getLoggedInUser() async {
    return handleHiveFailure(() async {
      debugLog('[HIVE_AUTH] getLoggedInUser()');
      final userModel = await _hiveAuthService.getLoggedInUser();
      if (userModel == null) {
        debugLog('[HIVE_AUTH] brak usera w Hive');
        throw Exception('Brak danych użytkownika');
      }
      debugLog('[HIVE_AUTH] loaded user ${userModel.email}');
      return UserMapper.toEntity(userModel);
    });
  }

  Future<void> saveLoggedInUser(UserEntity user) async {
    debugLog('[HIVE_AUTH] saveLoggedInUser ${user.email}');
    final userModel = UserMapper.toModel(user);
    await _hiveAuthService.saveLoggedInUser(userModel);
    debugLog('[HIVE_AUTH] user saved.');
  }

  Future<void> logout() async {
    debugLog('[HIVE_AUTH] logout, clearing user...');
    await _hiveAuthService.clearUser();
    debugLog('[HIVE_AUTH] user cleared.');
  }
}