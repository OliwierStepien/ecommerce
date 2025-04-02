import 'package:hive/hive.dart';
import 'package:mealapp/data/category/models/category.dart';

abstract class CategoryHiveService {
  Future<List<CategoryModel>> getCategories();
  Future<void> saveCategories(List<CategoryModel> categories);
}

class CategoryHiveServiceImpl extends CategoryHiveService {
  @override
  Future<List<CategoryModel>> getCategories() async {
    final box = await Hive.openBox<CategoryModel>('categories');
    return box.values.toList();
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    final box = await Hive.openBox<CategoryModel>('categories');
    await box.clear();
    await box.addAll(categories);
  }
}