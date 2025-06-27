import 'package:hive/hive.dart';
import 'package:mealapp/data/auth/model/user_model.dart';

abstract class HiveAuthService {
  Future<UserModel?> getLoggedInUser();
  Future<void> saveLoggedInUser(UserModel user);
  Future<void> clearUser();
}

class HiveAuthServiceImpl extends HiveAuthService {
  static const String userKey = 'currentUser';

  @override
  Future<UserModel?> getLoggedInUser() async {
    final box = Hive.box<UserModel>('users');
    return box.get(userKey);
  }

  @override
  Future<void> saveLoggedInUser(UserModel user) async {
    final box = Hive.box<UserModel>('users');
    await box.put(userKey, user);
  }

  @override
  Future<void> clearUser() async {
    final box = Hive.box<UserModel>('users');
    await box.delete(userKey);
  }
}