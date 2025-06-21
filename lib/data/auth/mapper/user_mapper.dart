import 'package:mealapp/data/auth/model/user_model.dart';
import 'package:mealapp/domain/auth/entity/user_entity.dart';

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