// data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart
import 'package:hive/hive.dart';
import 'package:mealapp/data/ingredient/model/ingredient_model.dart';
import 'package:mealapp/data/meal/model/meal_model.dart';

part 'shopping_list_meal_ingredient_model.g.dart';

@HiveType(typeId: 7)
class ShoppingListMealIngredientModel {
  @HiveField(0)
  final MealModel meal;

  @HiveField(1)
  final IngredientModel ingredient;

  @HiveField(2)
  final int portionCount;

  @HiveField(3)
  final bool isSynced;

  @HiveField(4)
  final bool isDeleted;

  /// 👇 NOWE: właściciel rekordu w Hive (UID użytkownika)
  @HiveField(5, defaultValue: '')
  final String ownerUid;

  const ShoppingListMealIngredientModel({
    required this.meal,
    required this.ingredient,
    required this.portionCount,
    required this.isSynced,
    required this.isDeleted,
    this.ownerUid = '',
  });

  ShoppingListMealIngredientModel copyWith({
    MealModel? meal,
    IngredientModel? ingredient,
    int? portionCount,
    bool? isSynced,
    bool? isDeleted,
    String? ownerUid,
  }) {
    return ShoppingListMealIngredientModel(
      meal: meal ?? this.meal,
      ingredient: ingredient ?? this.ingredient,
      portionCount: portionCount ?? this.portionCount,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  /// 🧠 Mapowanie pełnych danych (lokalnie w Hive)
  Map<String, dynamic> toMap() {
    final scaledAmount = ingredient.amountPerPortion != null
        ? ingredient.amountPerPortion! * portionCount
        : null;
    return {
      'meal': meal.toMap(),
      'ingredient': ingredient.toMap(),
      'portionCount': portionCount,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'scaledAmount': scaledAmount,
      'ownerUid': ownerUid, // 👈
    };
  }

  /// ☁️ Uproszczone mapowanie do Firestore (bez ownerUid – po stronie serwera jest auth)
  Map<String, dynamic> toFirestoreMap() {
    final scaledAmount = ingredient.amountPerPortion != null
        ? ingredient.amountPerPortion! * portionCount
        : null;

    return {
      // tylko potrzebne dane o posiłku
      'mealId': meal.mealId,
      'mealTitle': meal.title,

      // tylko potrzebne dane o składniku
      'ingredientId': ingredient.ingredientId,
      'ingredientName': ingredient.ingredientName,
      'amountPerPortion': ingredient.amountPerPortion,
      'unit': ingredient.unit,
      'ingredientCategory': ingredient.ingredientCategory,

      // metadane
      'portionCount': portionCount,
      'scaledAmount': scaledAmount,
      'isDeleted': isDeleted,
      'isSynced': isSynced,
    };
  }

  /// 🔄 Odczyt z mapy (z Hive lub Firestore)
  factory ShoppingListMealIngredientModel.fromMap(Map<String, dynamic> map) {
    final isFirestoreFormat =
        map.containsKey('mealId') && map.containsKey('ingredientId');

    if (isFirestoreFormat) {
      // 🔹 Format uproszczony (Firestore)
      return ShoppingListMealIngredientModel(
        meal: MealModel(
          title: map['mealTitle'] ?? '',
          mealId: map['mealId'] ?? '',
          categoryId: const [],
          image: '',
          ingredients: const [],
          steps: const [],
          isVegetarian: false,
          portion: 1,
        ),
        ingredient: IngredientModel(
          ingredientId: map['ingredientId'] ?? '',
          ingredientName: map['ingredientName'] ?? '',
          amountPerPortion: map['amountPerPortion'],
          unit: map['unit'] ?? '',
          ingredientCategory: map['ingredientCategory'] ?? '',
          mealId: map['mealId'] ?? '',
        ),
        portionCount: map['portionCount'] ?? 1,
        isSynced: map['isSynced'] ?? false,
        isDeleted: map['isDeleted'] ?? false,
        ownerUid: map['ownerUid'] ?? '', // może nie istnieć w FS – zostanie ''
      );
    } else {
      // 🔹 Format pełny (Hive)
      return ShoppingListMealIngredientModel(
        meal: MealModel.fromMap(map['meal']),
        ingredient: IngredientModel.fromMap(map['ingredient']),
        portionCount: map['portionCount'] ?? 1,
        isSynced: map['isSynced'] ?? false,
        isDeleted: map['isDeleted'] ?? false,
        ownerUid: map['ownerUid'] ?? '',
      );
    }
  }
}