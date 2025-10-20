import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class FirebasePlannedMealService {
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal);
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal);
  Future<List<PlannedMealModel>> getPlannedMeals();
  Future<void> removePlannedMealsInDateRange(DateTime start, DateTime end);
}

class FirebasePlannedMealServiceImpl implements FirebasePlannedMealService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebasePlannedMealServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userPlannedMealCollection() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('PlannedMeals');
  }

  String _generateDocId(PlannedMealModel plannedMeal) {
    return '${plannedMeal.date}_${plannedMeal.meal.mealId}';
  }

  @override
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal) async {
    return handleFirestoreException(() async {
      final docId = _generateDocId(plannedMeal);
      await _userPlannedMealCollection()
          .doc(docId)
          .set(plannedMeal.toMap())
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal) async {
    return handleFirestoreException(() async {
      final docId = _generateDocId(plannedMeal);
      await _userPlannedMealCollection()
          .doc(docId)
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<PlannedMealModel>> getPlannedMeals() async {
    return handleFirestoreException(() async {
      final returnedData = await _userPlannedMealCollection()
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs
          .map((doc) => PlannedMealModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> removePlannedMealsInDateRange(
      DateTime start, DateTime end) async {
    return handleFirestoreException(() async {
      // Pobierz wszystkie posiłki
      final allMeals = await getPlannedMeals();

      // Filtrowanie po zakresie dat
      final mealsToRemove = allMeals.where((m) {
        final date = DateTime(m.date.year, m.date.month, m.date.day);
        return date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)));
      });

      // Usuń wszystkie znalezione rekordy
      for (final meal in mealsToRemove) {
        final docId = _generateDocId(meal);
        await _userPlannedMealCollection()
            .doc(docId)
            .delete()
            .timeout(const Duration(seconds: 15));
      }
    });
  }
}
