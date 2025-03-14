import 'package:dartz/dartz.dart';
import 'package:mealapp/data/category/mapper/category_mapper.dart';
import 'package:mealapp/data/category/models/category.dart';
import 'package:mealapp/data/category/source/category_firebase_service.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/service_locator.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  @override
  Future<Either> getCategories() async {
    final categories = await sl<CategoryFirebaseService>().getCategories();
    return categories.fold(
      (error) {
        return Left(error);
      },
      (data) {
        return Right(
          List.from(data).map((e) => CategoryMapper.toEntity(CategoryModel.fromMap(e))).toList(),
        );
      },
    );
  }
}
