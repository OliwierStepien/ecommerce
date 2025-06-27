import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/data/category/repository/local/hive_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/remote/firebase_category_repository_impl.dart';
import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/service_locator.dart';

class CategoryRepositoryManager extends CategoryRepository {

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    final isOnline = await sl<NetworkInfo>().checkInternetConnection();
    debugPrint('[CategoryRepositoryManager] Connection status: ${isOnline ? 'ONLINE' : 'OFFLINE'}');
    debugPrint('[CategoryRepositoryManager] Using ${isOnline ? 'Firebase' : 'Hive'} data source');

    if (isOnline) {
      final result = await sl<FirebaseCategoryRepositoryImpl>().getCategories();
      
      result.fold(
        (failure) {
          debugPrint('[CategoryRepositoryManager] Firebase error: $failure');
        },
        (categories) async {
          debugPrint('[CategoryRepositoryManager] Saving ${categories.length} categories to Hive');
          await sl<HiveCategoryRepositoryImpl>().saveCategories(categories);
        },
      );
      
      return result;
    } else {
      final localResult = await sl<HiveCategoryRepositoryImpl>().getCategories();
      localResult.fold(
        (failure) => debugPrint('[CategoryRepositoryManager] Hive error: $failure'),
        (categories) => debugPrint('[CategoryRepositoryManager] Loaded ${categories.length} categories from Hive'),
      );
      return localResult;
    }
  }
}