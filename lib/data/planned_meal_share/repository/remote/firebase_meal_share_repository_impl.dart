import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/planned_meal/source/local/hive_planned_meal_service.dart';
import 'package:mealapp/data/planned_meal_share/source/remote/firebase_meal_share_service.dart';

class FirebaseMealShareRepositoryImpl {
  final FirebaseMealShareService _service;
  final HivePlannedMealService _hive;

  FirebaseMealShareRepositoryImpl(this._service, this._hive);

  Future<Either<Failure, void>> sharePlannedMealsWithFriend({
    required String friendUid,
    required DateTime start,
    required DateTime end,
  }) {
    return handleFirestoreFailure(() async {
      final allMeals = await _hive.getPlannedMeals();
      final inRange = allMeals.where((m) {
        final d = DateTime(m.date.year, m.date.month, m.date.day);
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList();

      await _service.sharePlannedMealsWithFriend(
        friendUid: friendUid,
        start: start,
        end: end,
        mealsToShare: inRange,
      );
      return;
    });
  }
}