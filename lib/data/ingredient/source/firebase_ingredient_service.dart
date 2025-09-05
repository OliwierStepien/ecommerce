import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/ingredient/model/ingredient_model.dart';

abstract class FirebaseIngredientService {
  Future<List<IngredientModel>> getIngredientsForMeals(List<String> mealIds);
  Future<List<IngredientModel>> getAllIngredients();
}

class FirebaseIngredientServiceImpl implements FirebaseIngredientService {
  final FirebaseFirestore _firestore;
  static const int _maxWhereInLimit = 10;

  FirebaseIngredientServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<IngredientModel>> getIngredientsForMeals(List<String> mealIds) {
    return handleFirestoreException(() async {
      // Dzielimy listę na partie (Firestore limit to 10 dla whereIn)
      final List<List<String>> chunks = [];
      for (var i = 0; i < mealIds.length; i += _maxWhereInLimit) {
        chunks.add(mealIds.sublist(
          i,
          i + _maxWhereInLimit > mealIds.length
              ? mealIds.length
              : i + _maxWhereInLimit,
        ));
      }

      final List<IngredientModel> allIngredients = [];

      for (final chunk in chunks) {
        final returnedData = await _firestore
            .collection("Ingredients")
            .where('mealId', whereIn: chunk)
            .get()
            .timeout(const Duration(seconds: 15));

        allIngredients.addAll(
          returnedData.docs
              .map((e) => IngredientModel.fromMap(e.data()))
              .toList(),
        );
      }

      return allIngredients;
    });
  }

  @override
  Future<List<IngredientModel>> getAllIngredients() {
    return handleFirestoreException(() async {
      final returnedData = await _firestore
          .collection("Ingredients")
          .get()
          .timeout(const Duration(seconds: 15));

      return returnedData.docs
          .map((e) => IngredientModel.fromMap(e.data()))
          .toList();
    });
  }
}