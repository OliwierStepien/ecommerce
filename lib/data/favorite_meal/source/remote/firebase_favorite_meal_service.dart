import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/favorite_meal/model/favorite_meal_model.dart';

abstract class FirebaseFavoriteMealService {
  Future<bool> addOrRemoveFavoriteMeal(FavoriteMealModel meal);
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
Future<bool> addOrRemoveFavoriteMeal(FavoriteMealModel meal) async {
  return handleFirestoreException(() async {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    final docRef = _firestore
        .collection("Users")
        .doc(user.uid)
        .collection('Favorites')
        .doc(meal.meal.mealId); // 👈 użyj mealId jako document ID

    final doc = await docRef.get().timeout(const Duration(seconds: 15));

    if (doc.exists) {
      await docRef.delete(); // 👈 usuń jeśli istnieje
      return false;
    } else {
      await docRef.set(meal.toMap()); // 👈 dodaj/aktualizuj
      return true;
    }
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
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));

      return returnedData.docs
          .map((doc) => FavoriteMealModel.fromMap(doc.data()))
          .toList();
    });
  }
}