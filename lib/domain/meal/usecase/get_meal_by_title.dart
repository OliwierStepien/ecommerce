import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class GetMealByTitleParams {
  final String title;
  final bool isVegetarian;
  const GetMealByTitleParams({required this.title, required this.isVegetarian});
}

class GetMealByTitleUseCase
    implements
        UseCase<Either<Failure, List<MealEntity>>, GetMealByTitleParams> {
  final MealRepository mealRepository;

  GetMealByTitleUseCase(this.mealRepository);

  @override
  Future<Either<Failure, List<MealEntity>>> call(
      GetMealByTitleParams params) async {
    if (params.isVegetarian) {
      return await mealRepository.getVegetarianMealsByTitle(params.title);
    } else {
      return await mealRepository.getMealsByTitle(params.title);
    }
  }
}
