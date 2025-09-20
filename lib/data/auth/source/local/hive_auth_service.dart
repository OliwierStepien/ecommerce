import 'package:hive/hive.dart';
import 'package:mealapp/data/auth/model/user_model.dart';

abstract class HiveAuthService {
  Future<UserModel?> getLoggedInUser();
  Future<void> saveLoggedInUser(UserModel user);
  Future<void> clearUser();
}

class HiveAuthServiceImpl extends HiveAuthService {
  Box<UserModel> get _box => Hive.box<UserModel>('users');

  static const String userKey = 'currentUser';

  @override
  Future<UserModel?> getLoggedInUser() async {
    return _box.get(userKey);
  }

  @override
  Future<void> saveLoggedInUser(UserModel user) async {
    await _box.put(userKey, user);
  }

  @override
  Future<void> clearUser() async {
    await _box.delete(userKey);
  }
}
