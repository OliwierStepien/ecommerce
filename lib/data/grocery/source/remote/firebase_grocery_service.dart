import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';

abstract class FirebaseGroceryService {
  Future<List<Map<String, dynamic>>> getGroceries();
}

class FirebaseGroceryServiceImpl implements FirebaseGroceryService {
  FirebaseGroceryServiceImpl({FirebaseFirestore? firestore})
      : _fs = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fs;

  @override
  Future<List<Map<String, dynamic>>> getGroceries() async {
    return handleFirestoreException(() async {
      final snap = await _fs
          .collection('Groceries')
          .get()
          .timeout(const Duration(seconds: 15));

      return snap.docs.map((d) => d.data()).toList();
    });
  }
}