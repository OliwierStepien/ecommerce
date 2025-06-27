import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/category/mapper/category_mapper.dart';
import 'package:mealapp/data/category/source/local/hive_category_service.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/service_locator.dart';

class HiveCategoryRepositoryImpl extends CategoryRepository {

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    return handleHiveFailure(() async {
      final categories = await sl<HiveCategoryService>().getCategories();
      return categories.map(CategoryMapper.toEntity).toList();
    });
  }

  Future<void> saveCategories(List<CategoryEntity> categories) async {
    await sl<HiveCategoryService>().saveCategories(categories.map(CategoryMapper.toModel).toList());
  }
}