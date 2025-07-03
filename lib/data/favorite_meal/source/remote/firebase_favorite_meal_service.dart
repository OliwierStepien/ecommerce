import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/favorite_meal/model/favorite_meal_model.dart';

abstract class FirebaseFavoriteMealService {
  Future<void> addFavoriteMeal(FavoriteMealModel meal);
  Future<void> removeFavoriteMeal(String mealId);
  Future<List<FavoriteMealModel>> getFavoritesMeals();
}

class FirebaseFavoriteMealServiceImpl implements FirebaseFavoriteMealService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFavoriteMealServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> addFavoriteMeal(FavoriteMealModel meal) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _firestore
          .collection("Users")
          .doc(user.uid)
          .collection('Favorites')
          .doc(meal.meal.mealId)
          .set(meal.toMap());
    });
  }

  @override
  Future<void> removeFavoriteMeal(String mealId) async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      await _firestore
          .collection("Users")
          .doc(user.uid)
          .collection('Favorites')
          .doc(mealId)
          .delete();
    });
  }

  @override
  Future<List<FavoriteMealModel>> getFavoritesMeals() async {
    return handleFirestoreException(() async {
      final user = _auth.currentUser;
      if (user == null) throw UnauthorizedException();

      final returnedData = await _firestore
          .collection("Users")
          .doc(user.uid)
          .collection('Favorites')
          .get()
          .timeout(const Duration(seconds: 15));

      return returnedData.docs
          .map((doc) => FavoriteMealModel.fromMap(doc.data()))
          .toList();
    });
  }
}