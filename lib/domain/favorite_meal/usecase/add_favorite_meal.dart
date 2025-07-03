import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/favorite_meal/entity/favorite_meal_entity.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class AddFavoriteMealUseCase
    implements UseCase<Either<Failure, void>, FavoriteMealEntity> {
  final FavoriteMealRepository favoriteMealRepository;

  AddFavoriteMealUseCase(this.favoriteMealRepository);

  @override
  Future<Either<Failure, void>> call({FavoriteMealEntity? params}) async {
    return await favoriteMealRepository.addFavoriteMeal(params!);
  }
}