import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class SignupUsecase implements UseCase<Either, UserCreationReq> {
  final AuthRepository authRepository;

  SignupUsecase(this.authRepository);

  @override
  Future<Either> call({UserCreationReq? params}) async {
    return await authRepository.signup(params!);
  }
}
