import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/core/network/network_info.dart';

class PlannedMealSyncService {
  final FirebasePlannedMealRepositoryImpl firebaseRepo;
  final HivePlannedMealRepositoryImpl hiveRepo;
  final NetworkInfo networkInfo;

  PlannedMealSyncService({
    required this.firebaseRepo,
    required this.hiveRepo,
    required this.networkInfo,
  });

  Future<Either<Failure, void>> syncData() async {
    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure());
    }

    final changesResult = await hiveRepo.getUnsyncedChanges();
    
    return changesResult.fold(
      (failure) => Left(failure),
      (changes) async {
        final box = Hive.box<PlannedMealModel>('plannedMeals');
        
        for (final entity in changes) {

          final key = '${entity.date}_${entity.meal.mealId}';
          final model = box.get(key);
          
          if (model == null) continue;
          
          if (model.isDeleted) {
            final result = await firebaseRepo.removePlannedMeal(entity.date, entity.meal.mealId);
            if (result.isLeft()) {
              return Left((result as Left).value);
            }
            await box.delete(key);
          } else {
            final result = await firebaseRepo.addPlannedMeal(entity);
            if (result.isLeft()) {
              return Left((result as Left).value);
            }
            await box.put(key, PlannedMealModel(
              date: entity.date,
              meal: MealMapper.toModel(entity.meal),
              isSynced: true,
              isDeleted: false,
            ));
          }
        }
        return const Right(null);
      },
    );
  }
}