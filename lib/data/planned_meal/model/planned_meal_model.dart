// data/planned_meal/model/planned_meal_model.dart
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

  @HiveField(4, defaultValue: 0)
  final int position;

  /// 👇 NOWE: właściciel rekordu w Hive (UID użytkownika)
  @HiveField(5, defaultValue: '')
  final String ownerUid;

  PlannedMealModel({
    required this.date,
    required this.meal,
    required this.position,
    this.isSynced = false,
    this.isDeleted = false,
    this.ownerUid = '',
  });

  PlannedMealModel copyWith({
    DateTime? date,
    MealModel? meal,
    bool? isSynced,
    bool? isDeleted,
    int? position,
    String? ownerUid,
  }) {
    return PlannedMealModel(
      date: date ?? this.date,
      meal: meal ?? this.meal,
      position: position ?? this.position,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'meal': meal.toMap(),
      'position': position,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'ownerUid': ownerUid, // 👈
    };
  }

  factory PlannedMealModel.fromMap(Map<String, dynamic> map) {
    return PlannedMealModel(
      date: (map['date'] as Timestamp).toDate(),
      meal: MealModel.fromMap(map['meal']),
      position: map['position'] ?? 0,
      isSynced: map['isSynced'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      ownerUid: map['ownerUid'] ?? '', // 👈
    );
  }
}