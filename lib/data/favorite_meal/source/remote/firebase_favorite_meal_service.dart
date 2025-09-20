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

  CollectionReference<Map<String, dynamic>> _userFavoriteMealCollection() {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();

    return _firestore.collection('Users').doc(user.uid).collection('Favorites');
  }

  String _generateDocId(FavoriteMealModel meal) {
    return meal.meal.mealId;
  }

  @override
  Future<void> addFavoriteMeal(FavoriteMealModel meal) async {
    return handleFirestoreException(() async {
      final docId = _generateDocId(meal);
      await _userFavoriteMealCollection()
          .doc(docId)
          .set(meal.toMap())
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<void> removeFavoriteMeal(String mealId) async {
    return handleFirestoreException(() async {
      await _userFavoriteMealCollection()
          .doc(mealId)
          .delete()
          .timeout(const Duration(seconds: 15));
    });
  }

  @override
  Future<List<FavoriteMealModel>> getFavoritesMeals() async {
    return handleFirestoreException(() async {
      final returnedData = await _userFavoriteMealCollection()
          .get()
          .timeout(const Duration(seconds: 15));

      return returnedData.docs
          .map((doc) => FavoriteMealModel.fromMap(doc.data()))
          .toList();
    });
  }
}
