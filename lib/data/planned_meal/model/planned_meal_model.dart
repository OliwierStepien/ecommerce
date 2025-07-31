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

  @HiveField(2, defaultValue: false)
  final bool isSynced;

  @HiveField(3, defaultValue: false)
  final bool isDeleted;

  PlannedMealModel({
    required this.date,
    required this.meal,
    this.isSynced = false,
    this.isDeleted = false,
  });

    PlannedMealModel copyWith({
    DateTime? date,
    MealModel? meal,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return PlannedMealModel(
      date: date ?? this.date,
      meal: meal ?? this.meal,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'meal': meal.toMap(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory PlannedMealModel.fromMap(Map<String, dynamic> map) {
    return PlannedMealModel(
      date: (map['date'] as Timestamp).toDate(),
      meal: MealModel.fromMap(map['meal']),
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}