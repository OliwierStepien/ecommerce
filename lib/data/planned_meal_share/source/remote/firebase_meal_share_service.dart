// data/planned_meal_share/source/remote/firebase_meal_share_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

class FirebaseMealShareService {
  final FirebaseFirestore _fs;
  final FirebaseAuth _auth;

  FirebaseMealShareService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _fs = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Kopiuje posiłki nadawcy do kolekcji odbiorcy:
  /// Users/{friendUid}/PlannedMeals/{date_mealId}
  Future<void> sharePlannedMealsWithFriend({
    required String friendUid,
    required DateTime start,
    required DateTime end,
    required List<PlannedMealModel> mealsToShare,
  }) async {
    final user = _auth.currentUser!;
    final batch = _fs.batch();

    final friendMealsRef = _fs
        .collection('Users')
        .doc(friendUid)
        .collection('PlannedMeals');

    for (final meal in mealsToShare) {
      final key = '${meal.date}_${meal.meal.mealId}';
      batch.set(friendMealsRef.doc(key), {
        'date': meal.date,
        'meal': meal.meal.toMap(),
        'position': meal.position,
        'isSynced': true,
        'isDeleted': false,
        'sharedFromUid': user.uid,
        'sharedAt': FieldValue.serverTimestamp(),
        // 👇 dodane: przypisz właściciela po stronie odbiorcy
        'ownerUid': friendUid,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}