import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:mealapp/data/meal/mapper/meal_mapper.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class MealFirebaseService {
  Future<Either> getMeals();
  Future<Either> getMealsByCategoryId(String categoryId);
  Future<Either> getMealsByTitle(String title);
  Future<Either> addOrRemoveFavoriteMeal(MealEntity meal);
  Future<bool> isFavorite(String mealId);
  Future<Either> getFavoritesMeals();
}

class MealFirebaseServiceImpl extends MealFirebaseService {
  @override
  Future<Either> getMeals() async {
    try {
      final returnedData =
          await FirebaseFirestore.instance.collection("Meals").get();
      return Right(returnedData.docs.map((e) => e.data()).toList());
    } catch (e) {
      return const Left('Error Message');
    }
  }

  @override
  Future<Either> getMealsByCategoryId(String categoryId) async {
    try {
      final returnedData = await FirebaseFirestore.instance
          .collection("Meals")
          .where(
            'categoriesId',
            arrayContains: categoryId,
          )
          .get();
      return Right(returnedData.docs.map((e) => e.data()).toList());
    } catch (e) {
      return const Left('Error Message');
    }
  }

  @override
  Future<Either> getMealsByTitle(String title) async {
    try {
      final returnedData =
          await FirebaseFirestore.instance.collection("Meals").get();
      final filteredMeals = returnedData.docs
          .map((e) => e.data())
          .where((meal) =>
              meal['title'].toLowerCase().contains(title.toLowerCase()))
          .toList();
      return Right(filteredMeals);
    } catch (e) {
      return const Left('Error Message');
    }
  }

  @override
  Future<Either> addOrRemoveFavoriteMeal(MealEntity meal) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final meals = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('Favorites')
          .where('mealId', isEqualTo: meal.mealId)
          .get();

      if (meals.docs.isNotEmpty) {
        await meals.docs.first.reference.delete();
        return const Right(false);
      } else {
        final mealModel = MealMapper.toModel(meal);
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .collection('Favorites')
            .add(mealModel.toMap());
        return const Right(true);
      }
    } catch (e) {
      return const Left('Spróbuj ponownie');
    }
  }

  @override
  Future<bool> isFavorite(String mealId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final meals = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('Favorites')
          .where('mealId', isEqualTo: mealId)
          .get();

      if (meals.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either> getFavoritesMeals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final returnedData = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection('Favorites')
          .get();
      return Right(returnedData.docs.map((e) => e.data()).toList());
    } catch (e) {
      return const Left('Please try again');
    }
  }
}
