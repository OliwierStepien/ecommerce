import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/meal/mapper/ingredient_mapper.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/mapper/shopping_list_meal_ingredient_mapper.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/domain/meal/entity/ingredient_entity.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';


class HiveShoppingListMealIngredientRepositoryImpl
   implements ShoppingListMealIngredientRepository {
 final HiveShoppingListMealIngredientService
     _hiveShoppingListMealIngredientService;


 HiveShoppingListMealIngredientRepositoryImpl({
   required HiveShoppingListMealIngredientService
       hiveShoppingListMealIngredientService,
 })  : _hiveShoppingListMealIngredientService =
           hiveShoppingListMealIngredientService;


 @override
 Future<Either<Failure, void>> addMealIngredientToShoppingList(
     MealEntity meal, IngredientEntity ingredient, int portionCount) async {
   return handleHiveFailure(() async {
     await _hiveShoppingListMealIngredientService
         .addMealIngredientToShoppingList(
       ShoppingListMealIngredientMapper.toModel(
           meal, ingredient, portionCount),
     );
   });
 }


 @override
 Future<Either<Failure, void>> removeMealIngredientFromShoppingList(
     MealEntity meal, IngredientEntity ingredient) async {
   return handleHiveFailure(() async {
     await _hiveShoppingListMealIngredientService
         .removeMealIngredientFromShoppingList(
       ShoppingListMealIngredientMapper.toModel(meal, ingredient, 1),
     );
   });
 }


 @override
 Future<Either<Failure, List<MealEntity>>>
     getMealIngredientToShoppingList() async {
   return handleHiveFailure(() async {
     final models = await _hiveShoppingListMealIngredientService
         .getMealIngredientFromShoppingList();
     return _groupIngredientsByMeal(models);
   });
 }


 @override
 Future<Either<Failure, List<MealEntity>>>
     getUnsyncedShoppingListMealIngredient() async {
   return handleHiveFailure(() async {
     final models = await _hiveShoppingListMealIngredientService
         .getUnsyncedShoppingListMealIngredient();
     return _groupIngredientsByMeal(models);
   });
 }


 @override
 Future<Either<Failure, List<MealEntity>>>
     getUnsyncedChangesForShoppingListMealIngredient() async {
   return handleHiveFailure(() async {
     final models = await _hiveShoppingListMealIngredientService
         .getUnsyncedChangesForShoppingListMealIngredient();
     return _groupIngredientsByMeal(models);
   });
 }


 @override
 Future<Either<Failure, void>> markShoppingListMealIngredientAsSynced(
     String mealId) async {
   return handleHiveFailure(() async {
     // Pobierz wszystkie niesynchronizowane wpisy dla danego mealId
     final unsyncedItems = (await _hiveShoppingListMealIngredientService
             .getUnsyncedChangesForShoppingListMealIngredient())
         .where((model) => model.meal.mealId == mealId);


     // Oznacz każdy składnik jako zsynchronizowany
     for (final model in unsyncedItems) {
       await _hiveShoppingListMealIngredientService
           .markShoppingListMealIngredientAsSynced(
         mealId,
         model.ingredient.ingredientId,
       );
     }
   });
 }


 // Pomocnicza metoda do grupowania składników po posiłkach
 List<MealEntity> _groupIngredientsByMeal(
     List<ShoppingListMealIngredientModel> models) {
   final mealsMap = <String, MealEntity>{};


   for (final model in models) {
     final mealId = model.meal.mealId;


     if (!mealsMap.containsKey(mealId)) {
       mealsMap[mealId] = MealMapper.toEntity(model.meal);
     }


     mealsMap[mealId]!.ingredients.add(
           IngredientMapper.toEntity(model.ingredient),
         );
   }


   return mealsMap.values.toList();
 }


 @override
 Future<Either<Failure, void>> restoreMealIngredientToShoppingList(
     MealEntity meal, IngredientEntity ingredient, int portionCount) async {
   return handleHiveFailure(() async {
     await _hiveShoppingListMealIngredientService
         .restoreMealIngredientToShoppingList(
       ShoppingListMealIngredientMapper.toModel(
           meal, ingredient, portionCount),
     );
   });
 }
}