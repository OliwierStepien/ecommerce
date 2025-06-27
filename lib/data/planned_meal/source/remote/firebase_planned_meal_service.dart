import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/domain/planned_meal/entity/planned_meal_entity.dart';

abstract class FirebasePlannedMealService {
  Future<void> addPlannedMeal(PlannedMealEntity plannedMeal);
  Future<void> removePlannedMeal(DateTime date, String mealId);
  Future<List<Map<String, dynamic>>> getPlannedMeals();
}

class FirebasePlannedMealServiceImpl implements FirebasePlannedMealService {
  @override
  Future<void> addPlannedMeal(PlannedMealEntity plannedMeal) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('PlannedMeals')
        .doc('${plannedMeal.date}_${plannedMeal.meal.mealId}')
        .set({
          'date': plannedMeal.date,
          'meal': MealMapper.toModel(plannedMeal.meal).toMap(),
        });
  }

  @override
  Future<void> removePlannedMeal(DateTime date, String mealId) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('PlannedMeals')
        .doc('${date}_$mealId')
        .delete();
  }

  @override
  Future<List<Map<String, dynamic>>> getPlannedMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('PlannedMeals')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}