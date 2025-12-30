import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';

abstract class GroceryRepository {
  Future<Either<Failure, List<GroceryEntity>>> getGroceries();
  Future<Either<Failure, List<GroceryEntity>>> saveGroceries(
    List<GroceryEntity> groceries,
  );
}