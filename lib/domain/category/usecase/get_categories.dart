import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

class GetCategoriesUseCase
    implements UseCase<Either<Failure, List<CategoryEntity>>, NoParams> {
  final CategoryRepository categoryRepository;

  GetCategoriesUseCase(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await categoryRepository.getCategories();
  }
}