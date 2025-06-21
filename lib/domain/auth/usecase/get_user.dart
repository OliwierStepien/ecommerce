import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class GetUserUsecase implements UseCase<Either, void> {
  final AuthRepository authRepository;

  GetUserUsecase(this.authRepository);

  @override
  Future<Either> call({void params}) async {
    return await authRepository.getUser();
  }
}
