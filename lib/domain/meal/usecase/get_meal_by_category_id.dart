import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class GetMealsByCategoryParams {
  final String categoryId;
  final bool isVegetarian;
  const GetMealsByCategoryParams(
      {required this.categoryId, required this.isVegetarian});
}

class GetMealByCategoryIdUseCase
    implements
        UseCase<Either<Failure, List<MealEntity>>, GetMealsByCategoryParams> {
  final MealRepository mealRepository;

  GetMealByCategoryIdUseCase(this.mealRepository);

  @override
  Future<Either<Failure, List<MealEntity>>> call(
      GetMealsByCategoryParams params) async {
    if (params.isVegetarian) {
      return await mealRepository
          .getVegetarianMealsByCategoryId(params.categoryId);
    } else {
      return await mealRepository.getMealsByCategoryId(params.categoryId);
    }
  }
}
