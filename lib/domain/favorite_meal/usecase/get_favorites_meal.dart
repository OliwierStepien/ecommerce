import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class GetFavoritesMealUseCase implements UseCase<Either<Failure, List<FavoriteMealEntity>>, NoParams> {
    final FavoriteMealRepository favoriteMealRepository;

  GetFavoritesMealUseCase(this.favoriteMealRepository);

  @override
  Future<Either<Failure, List<FavoriteMealEntity>>> call(NoParams params) async {
    return await favoriteMealRepository.getFavoritesMeals();
  }
}
