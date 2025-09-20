import 'package:hive/hive.dart';
import 'package:mealapp/data/category/model/category_model.dart';

abstract class HiveCategoryService {
  Future<List<CategoryModel>> getCategories();
  Future<void> saveCategories(List<CategoryModel> categories);
}

class HiveCategoryServiceImpl extends HiveCategoryService {
  Box<CategoryModel> get _box => Hive.box<CategoryModel>('categories');

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _box.values.toList();
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _box.clear();
    await _box.addAll(categories);
  }
}
