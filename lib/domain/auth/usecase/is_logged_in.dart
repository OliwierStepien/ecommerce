import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class IsLoggedInUseCase implements UseCase<bool, NoParams> {
  final AuthRepository authRepository;

  IsLoggedInUseCase(this.authRepository);

  @override
  Future<bool> call(NoParams params) async {
    return await authRepository.isLoggedIn();
  }
}
