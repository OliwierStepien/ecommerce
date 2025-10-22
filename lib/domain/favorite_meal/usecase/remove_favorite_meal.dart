import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';

class RemoveFavoriteMealUseCase
    implements UseCase<Either<Failure, void>, String> {
  final FavoriteMealRepository favoriteMealRepository;

  RemoveFavoriteMealUseCase(this.favoriteMealRepository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await favoriteMealRepository.removeFavoriteMeal(params);
  }
}