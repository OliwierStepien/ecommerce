import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

abstract class ShoppingListClearRepository {
  Future<Either<Failure, void>> clearAll();
}