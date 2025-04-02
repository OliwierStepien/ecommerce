import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

Future<Either<Failure, T>> handleHiveFailure<T>(
  Future<T> Function() operation,
) async {
  try {
    final result = await operation();
    return Right(result);
  } on HiveError catch (_) {
    return Left(CacheFailure());
  } on CacheException {
    return Left(CacheFailure());
  } catch (e) {
    return Left(CacheFailure());
  }
}