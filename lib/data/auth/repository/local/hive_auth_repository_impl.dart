import 'package:dartz/dartz.dart';
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
      final userModel = await _hiveAuthService.getLoggedInUser();
      return UserMapper.toEntity(userModel!);
    });
  }

  Future<void> saveLoggedInUser(UserEntity user) async {
    final userModel = UserMapper.toModel(user);
    await _hiveAuthService.saveLoggedInUser(userModel);
  }

  Future<void> logout() async {
    await _hiveAuthService.clearUser();
  }
}
