import 'package:mealapp/data/category/model/category.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';

class CategoryMapper {
  static CategoryEntity toEntity(CategoryModel model) {
    return CategoryEntity(
      title: model.title,
      categoryId: model.categoryId,
      image: model.image,
    );
  }

  static CategoryModel toModel(CategoryEntity entity) {
    return CategoryModel(
      title: entity.title,
      categoryId: entity.categoryId,
      image: entity.image,
    );
  }
}