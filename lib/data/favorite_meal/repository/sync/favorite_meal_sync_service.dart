import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/sync/sync_service.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/data/favorite_meal/model/favorite_meal_model.dart';
import 'package:mealapp/data/favorite_meal/repository/local/hive_favorite_meal_repository_impl.dart';
import 'package:mealapp/data/favorite_meal/repository/remote/firebase_favorite_meal_repository_impl.dart';

class FavoriteMealSyncService implements SyncService {
  final FirebaseFavoriteMealRepositoryImpl firebaseRepo;
  final HiveFavoriteMealRepositoryImpl hiveRepo;
  final NetworkInfo networkInfo;

  FavoriteMealSyncService({
    required this.firebaseRepo,
    required this.hiveRepo,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> syncData() async {
    final isOnline = await networkInfo.checkInternetConnection();
    if (!isOnline) {
      return Left(NetworkFailure());
    }

    final changesResult = await hiveRepo.getUnsyncedChangesForFavoriteMeals();
    
    return changesResult.fold(
      (failure) => Left(failure),
      (changes) async {
        final box = Hive.box<FavoriteMealModel>('favoritesMeals');

        for (final entity in changes) {
          final key = entity.meal.mealId;
          final model = box.get(key);
          if (model == null) continue;

          if (model.isDeleted) {
            final result = await firebaseRepo.removeFavoriteMeal(key);
            if (result.isLeft()) return Left((result as Left).value);

            await box.delete(key);
          } else {
            final result = await firebaseRepo.addFavoriteMeal(entity);
            if (result.isLeft()) return Left((result as Left).value);

            await box.put(key, FavoriteMealModel(
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