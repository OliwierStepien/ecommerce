import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/handle_hive_failure.dart';
import 'package:mealapp/data/grocery/mapper/grocery_mapper.dart';
import 'package:mealapp/data/grocery/source/local/hive_grocery_service.dart';
import 'package:mealapp/domain/grocery/entity/grocery_entity.dart';
import 'package:mealapp/domain/grocery/repository/grocery_repository.dart';

class HiveGroceryRepositoryImpl extends GroceryRepository {
  final HiveGroceryService _hiveGroceryService;

  HiveGroceryRepositoryImpl({
    required HiveGroceryService hiveGroceryService,
  }) : _hiveGroceryService = hiveGroceryService;

  @override
  Future<Either<Failure, List<GroceryEntity>>> getGroceries() async {
    return handleHiveFailure(() async {
      final models = await _hiveGroceryService.getGroceries();
      return models.map(GroceryMapper.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<GroceryEntity>>> saveGroceries(
    List<GroceryEntity> groceries,
  ) async {
    return handleHiveFailure(() async {
      await _hiveGroceryService.saveGroceries(
        groceries.map(GroceryMapper.toModel).toList(),
      );
      return groceries;
    });
  }
}