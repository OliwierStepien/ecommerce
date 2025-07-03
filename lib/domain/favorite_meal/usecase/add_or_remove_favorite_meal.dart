import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class AddOrRemoveFavoriteMealUseCase
    implements UseCase<Either<Failure, bool>, FavoriteMealEntity> {
  final FavoriteMealRepository favoriteMealRepository;

  AddOrRemoveFavoriteMealUseCase(this.favoriteMealRepository);

  @override
  Future<Either<Failure, bool>> call({FavoriteMealEntity? params}) async {
    return await favoriteMealRepository.addOrRemoveFavoriteMeal(params!);
  }
}
