import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/service_locator.dart';

class GetCategoriesUseCase
    implements UseCase<Either<Failure, List<CategoryEntity>>, dynamic> {
  @override
  Future<Either<Failure, List<CategoryEntity>>> call({dynamic params}) async {
    return await sl<CategoryRepository>().getCategories();
  }
}
