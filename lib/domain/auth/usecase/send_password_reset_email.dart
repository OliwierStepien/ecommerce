import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class SendPasswordResetEmailUseCase implements UseCase<Either, String> {
  final AuthRepository authRepository;

  SendPasswordResetEmailUseCase(this.authRepository);

  @override
  Future<Either> call(String params) async {
    return await authRepository.sendPasswordResetEmail(params);
  }
}