import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

part 'planned_meal_model.g.dart';

@HiveType(typeId: 5)
class PlannedMealModel {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final MealModel meal;

  PlannedMealModel({
    required this.date,
    required this.meal,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'meal': meal.toMap(),
    };
  }

  factory PlannedMealModel.fromMap(Map<String, dynamic> map) {
    return PlannedMealModel(
      date: (map['date'] as Timestamp).toDate(),
      meal: MealModel.fromMap(map['meal']),
    );
  }
}