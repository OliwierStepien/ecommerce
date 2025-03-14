import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/service_locator.dart';

class IsLoggedInUseCase implements UseCase<bool, dynamic> {
  @override
  Future<bool> call({dynamic params}) async {
    return await sl<AuthRepository>().isLoggedIn();
  }
}
