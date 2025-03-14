import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class SigninUsecase implements UseCase<Either, UserSigninReq> {
  @override
  Future<Either> call({UserSigninReq? params}) async {
    return await sl<AuthRepository>().signin(params!);
  }
}
