import 'package:dartz/dartz.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
}
