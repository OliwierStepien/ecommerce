import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class SignoutUsecase implements UseCase<Either, NoParams> {
  final AuthRepository authRepository;

  SignoutUsecase(this.authRepository);

  @override
  Future<Either> call(NoParams params) async {
    return await authRepository.signout();
  }
}
