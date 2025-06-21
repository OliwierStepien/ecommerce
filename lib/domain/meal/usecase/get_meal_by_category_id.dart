import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';

class GetMealByCategoryIdUseCase
    implements
        UseCase<Either<Failure, List<MealEntity>>, Map<String, dynamic>> {
  final MealRepository mealRepository;

  GetMealByCategoryIdUseCase(this.mealRepository);

  @override
  Future<Either<Failure, List<MealEntity>>> call(
      {Map<String, dynamic>? params}) async {
    final categoryId = params?['categoryId'] as String;
    final isVegetarian = params?['isVegetarian'] as bool;

    if (isVegetarian) {
      return await mealRepository.getVegetarianMealsByCategoryId(categoryId);
    } else {
      return await mealRepository.getMealsByCategoryId(categoryId);
    }
  }
}
