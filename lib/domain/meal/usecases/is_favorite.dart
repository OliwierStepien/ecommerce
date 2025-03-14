import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class IsFavoriteUseCase implements UseCase<bool, String> {
  @override
  Future<bool> call({String? params}) async {
    return await sl<MealRepository>().isFavorite(params!);
  }
}
