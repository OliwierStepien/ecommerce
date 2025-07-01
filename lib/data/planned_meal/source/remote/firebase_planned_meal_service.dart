import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

abstract class FirebasePlannedMealService {
  Future<void> addPlannedMeal(PlannedMealEntity plannedMeal);
  Future<void> removePlannedMeal(DateTime date, String mealId);
  Future<List<Map<String, dynamic>>> getPlannedMeals();
}

class FirebasePlannedMealServiceImpl implements FirebasePlannedMealService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebasePlannedMealServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('PlannedMeals')
          .doc('${plannedMeal.date}_${plannedMeal.meal.mealId}')
          .set({
        'date': plannedMeal.date,
        'meal': MealMapper.toModel(plannedMeal.meal).toMap(),
        'isSynced': true,
        'isDeleted': false,
      }).timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removePlannedMeal(DateTime date, String mealId) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('PlannedMeals')
          .doc('${date}_$mealId')
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPlannedMeals() async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();
      final returnedData = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('PlannedMeals')
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }
}