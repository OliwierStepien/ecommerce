import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class FirebasePlannedMealService {
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal);
  Future<void> removePlannedMeal(DateTime date, String mealId);
  Future<List<PlannedMealModel>> getPlannedMeals();
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
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('PlannedMeals')
          .doc('${plannedMeal.date}_${plannedMeal.meal.mealId}')
          .set(plannedMeal.toMap())
          .timeout(const Duration(seconds: 15));
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
  Future<List<PlannedMealModel>> getPlannedMeals() async {
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
      return returnedData.docs
          .map((doc) => PlannedMealModel.fromMap(doc.data()))
          .toList();
    });
  }
}