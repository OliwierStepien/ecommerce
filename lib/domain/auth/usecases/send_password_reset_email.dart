import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class SendPasswordResetEmailUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String? params}) async {
    return await sl<AuthRepository>().sendPasswordResetEmail(params!);
  }
}
