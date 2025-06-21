import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class GetFavoritesMealUseCase implements UseCase<Either<Failure, List<MealEntity>>, void> {
    final MealRepository mealRepository;

  GetFavoritesMealUseCase(this.mealRepository);

  @override
  Future<Either<Failure, List<MealEntity>>> call({void params}) async {
    return await mealRepository.getFavoritesMeals();
  }
}
