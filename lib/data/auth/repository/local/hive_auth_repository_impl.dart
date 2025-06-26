import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/auth/source/local/auth_hive_service.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';
import 'package:mealapp/data/auth/mapper/user_mapper.dart';
import 'package:mealapp/service_locator.dart';

class HiveAuthRepositoryImpl {
  Future<Either<Failure, UserEntity>> getLoggedInUser() async {
    return handleHiveFailure(() async {
      final userModel = await sl<AuthHiveService>().getLoggedInUser();
      return UserMapper.toEntity(userModel!);
    });
  }

  Future<void> saveLoggedInUser(UserEntity user) async {
    final userModel = UserMapper.toModel(user);
    await sl<AuthHiveService>().saveLoggedInUser(userModel);
  }

  Future<void> logout() async {
    await sl<AuthHiveService>().clearUser();
  }
}