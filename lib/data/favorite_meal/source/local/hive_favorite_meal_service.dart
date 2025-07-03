import 'package:hive/hive.dart';
import 'package:mealapp/data/favorite_meal/model/favorite_meal_model.dart';

abstract class HiveFavoriteMealService {
  Future<List<FavoriteMealModel>> getFavoriteMeals();
  Future<void> saveFavoriteMeal(FavoriteMealModel meal);
  Future<void> removeFavoriteMeal(String mealId, {bool isOnline});
  Future<List<FavoriteMealModel>> getUnsyncedFavoriteMeals();
  Future<List<FavoriteMealModel>> getUnsyncedChanges();
  Future<void> markFavoriteMealAsSynced(String mealId);
}

class HiveFavoriteMealServiceImpl implements HiveFavoriteMealService {
  Box<FavoriteMealModel> get _box =>
      Hive.box<FavoriteMealModel>('favoritesMeals');

  @override
  Future<List<FavoriteMealModel>> getFavoriteMeals() async {
    return _box.values.where((model) => !model.isDeleted).toList();
  }

  @override
  Future<void> saveFavoriteMeal(FavoriteMealModel meal) async {
    final key = meal.meal.mealId;
    await _box.put(
      key,
      FavoriteMealModel(
        meal: meal.meal,
        isSynced: false,
        isDeleted: false,
      ),
    );
    print("Ulubione posiłki (Hive): ${_box.values.where((m) => !m.isDeleted).length}");
  }

  @override
Future<void> removeFavoriteMeal(String mealId, {bool isOnline = false}) async {
  if (isOnline) {
    await _box.delete(mealId);
    print("Ulubione posiłki (Hive): ${_box.values.where((m) => !m.isDeleted).length}");
  } else {
    final existing = _box.get(mealId);
    if (existing != null) {
      await _box.put(
        mealId,
        FavoriteMealModel(
          meal: existing.meal,
          isSynced: false,
          isDeleted: true,
        ),
      );
      print("Ulubione posiłki (Hive): ${_box.values.where((m) => !m.isDeleted).length}");
    }
  }
}

  @override
  Future<List<FavoriteMealModel>> getUnsyncedFavoriteMeals() async {
    return _box.values
        .where((model) => !model.isSynced && !model.isDeleted)
        .toList();
  }

  @override
  Future<List<FavoriteMealModel>> getUnsyncedChanges() async {
    return _box.values.where((model) => !model.isSynced).toList();
  }

  @override
  Future<void> markFavoriteMealAsSynced(String mealId) async {
    final model = _box.get(mealId);
    if (model != null && !model.isDeleted) {
      await _box.put(
        mealId,
        FavoriteMealModel(
          meal: model.meal,
          isSynced: true,
          isDeleted: false,
        ),
      );
    }
  }
}
