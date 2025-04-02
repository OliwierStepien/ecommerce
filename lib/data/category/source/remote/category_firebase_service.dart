import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';

abstract class CategoryFirebaseService {
  Future<List<Map<String, dynamic>>> getCategories();
}

class CategoryFirebaseServiceImpl extends CategoryFirebaseService {
  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseFirestore.instance
          .collection("Categories")
          .get()
          .timeout(const Duration(seconds: 15));
      return returnedData.docs.map((e) => e.data()).toList();
    });
  }
}
