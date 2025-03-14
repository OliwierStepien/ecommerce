import 'package:dartz/dartz.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/service_locator.dart';

class GetCategoriesUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic params}) async {
    return await sl<CategoryRepository>().getCategories();
  }
}
