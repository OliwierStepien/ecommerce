import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class SigninUsecase implements UseCase<Either, UserSigninReq> {
    final AuthRepository authRepository;

  SigninUsecase(this.authRepository);

  @override
  Future<Either> call(UserSigninReq params) async {
    return await authRepository.signin(params);
  }
}
