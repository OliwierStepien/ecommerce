import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';

class IsLoggedInUseCase implements UseCase<bool, void> {
  final AuthRepository authRepository;

  IsLoggedInUseCase(this.authRepository);

  @override
  Future<bool> call({void params}) async {
    return await authRepository.isLoggedIn();
  }
}
