import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/service_locator.dart';

class IsFavoriteUseCase implements UseCase<Either<Failure, bool>, String> {
  @override
  Future<Either<Failure, bool>> call({String? params}) async {
    return await sl<MealRepository>().isFavorite(params!);
  }
}
