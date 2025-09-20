import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/ingredient/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/ingredient/source/firebase_ingredient_service.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';

class FirebaseIngredientRepositoryImpl implements IngredientRepository {
  final FirebaseIngredientService _firebaseIngredientService;

  FirebaseIngredientRepositoryImpl(
      {required FirebaseIngredientService firebaseIngredientService})
      : _firebaseIngredientService = firebaseIngredientService;

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(
      String mealId) {
    return handleFirestoreFailure(() async {
      final ingredients =
          await _firebaseIngredientService.getIngredientsForMeals([mealId]);
      return ingredients.map(IngredientMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() {
    return handleFirestoreFailure(() async {
      final ingredients = await _firebaseIngredientService.getAllIngredients();
      return ingredients.map(IngredientMapper.toEntity).toList();
    });
  }
}
