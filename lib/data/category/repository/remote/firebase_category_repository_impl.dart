import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/category/mapper/category_mapper.dart';
import 'package:mealapp/data/category/models/category.dart';
import 'package:mealapp/data/category/source/remote/category_firebase_service.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/service_locator.dart';

class FirebaseCategoryRepositoryImpl extends CategoryRepository {

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    return handleFirestoreFailure(() async {
      final categories = await sl<CategoryFirebaseService>().getCategories();
      final mappedData = categories
          .map((e) => CategoryMapper.toEntity(CategoryModel.fromMap(e)))
          .toList();
      return mappedData;
    });
  }
}