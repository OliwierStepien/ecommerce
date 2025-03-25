import 'package:mealapp/data/auth/models/user.dart';
import 'package:mealapp/domain/auth/entity/user.dart';

class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      userId: model.userId,
      firstName: model.firstName,
      email: model.email,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      firstName: entity.firstName,
      email: entity.email,
    );
  }
}