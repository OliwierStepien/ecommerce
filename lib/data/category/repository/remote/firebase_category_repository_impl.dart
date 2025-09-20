import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_firestore_failure.dart';
import 'package:mealapp/data/category/mapper/category_mapper.dart';
import 'package:mealapp/data/category/model/category_model.dart';
import 'package:mealapp/data/category/source/remote/firebase_category_service.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

class FirebaseCategoryRepositoryImpl extends CategoryRepository {
  final FirebaseCategoryService _firebaseCategoryService;

  FirebaseCategoryRepositoryImpl(
      {required FirebaseCategoryService firebaseCategoryService})
      : _firebaseCategoryService = firebaseCategoryService;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    return handleFirestoreFailure(() async {
      final categories = await _firebaseCategoryService.getCategories();
      final mappedData = categories
          .map((e) => CategoryMapper.toEntity(CategoryModel.fromMap(e)))
          .toList();
      return mappedData;
    });
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> saveCategories(
      List<CategoryEntity> categories) async {
    return handleFirestoreFailure(() async {
      return [];
    });
  }
}
