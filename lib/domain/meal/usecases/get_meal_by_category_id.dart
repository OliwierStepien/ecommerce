import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class GetMealByCategoryIdUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String? params}) async {
    return await sl<MealRepository>().getMealsByCategoryId(params!);
  }
}
