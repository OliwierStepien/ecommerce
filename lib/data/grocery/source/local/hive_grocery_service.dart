import 'package:hive/hive.dart';
import 'package:mealapp/data/grocery/model/grocery_model.dart';

abstract class HiveGroceryService {
  Future<List<GroceryModel>> getGroceries();
  Future<void> saveGroceries(List<GroceryModel> groceries);
}

class HiveGroceryServiceImpl extends HiveGroceryService {
  Box<GroceryModel> get _box => Hive.box<GroceryModel>('groceries');

  @override
  Future<List<GroceryModel>> getGroceries() async {
    return _box.values.toList();
  }

  @override
  Future<void> saveGroceries(List<GroceryModel> groceries) async {
    await _box.clear();
    await _box.addAll(groceries);
  }
}