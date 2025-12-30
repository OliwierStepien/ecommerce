import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/grocery/mapper/grocery_mapper.dart';
import 'package:mealapp/data/grocery/model/grocery_model.dart';
import 'package:mealapp/data/grocery/source/remote/firebase_grocery_service.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';
import 'package:mealapp/domain/grocery/repository/grocery_repository.dart';

class FirebaseGroceryRepositoryImpl implements GroceryRepository {
  final FirebaseGroceryService _service;

  FirebaseGroceryRepositoryImpl({required FirebaseGroceryService service})
      : _service = service;

  @override
  Future<Either<Failure, List<GroceryEntity>>> getGroceries() async {
    return handleFirestoreFailure(() async {
      final raw = await _service.getGroceries();
      return raw
          .map((e) => GroceryMapper.toEntity(GroceryModel.fromMap(e)))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<GroceryEntity>>> saveGroceries(
    List<GroceryEntity> groceries,
  ) async {
    // Zapis robisz tylko lokalnie w Hive przez GroceryRepositoryManager.
    return handleFirestoreFailure(() async {
      return <GroceryEntity>[];
    });
  }
}
