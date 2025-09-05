import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/ingredient/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/source/local/hive_meal_service.dart';
import 'package:mealapp/domain/ingredient/entity/ingredient_entity.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';
import 'package:mealapp/service_locator.dart';

class HiveIngredientRepositoryImpl extends IngredientRepository {

  @override
  Future<Either<Failure, List<IngredientEntity>>> getAllIngredients() async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final allIngredients = <IngredientEntity>[];
      
      for (final meal in meals) {
        allIngredients.addAll(
          meal.ingredients.map((ingredient) => IngredientMapper.toEntity(ingredient))
        );
      }
      
      return allIngredients;
    });
  }

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredientsForMeal(String mealId) async {
    return handleHiveFailure(() async {
      final meals = await sl<HiveMealService>().getMeals();
      final meal = meals.firstWhere((m) => m.mealId == mealId);
      return meal.ingredients.map(IngredientMapper.toEntity).toList();
    });
  }
}