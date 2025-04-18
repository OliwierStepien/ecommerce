import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class SignoutUsecase implements UseCase<Either, void> {
  @override
  Future<Either> call({void params}) async {
    return await sl<AuthRepository>().signout();
  }
}
