import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';

class GetAllIngredientsUseCase
    implements
        UseCase<Either<Failure, List<IngredientEntity>>, Map<String, dynamic>> {
  final IngredientRepository repository;

  GetAllIngredientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<IngredientEntity>>> call(
      {Map<String, dynamic>? params}) async {
    return await repository.getAllIngredients();
  }
}
