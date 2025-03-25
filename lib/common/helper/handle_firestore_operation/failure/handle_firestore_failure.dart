import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

Future<Either<Failure, T>> handleFirestoreFailure<T>(
    Future<T> Function() operation) async {
  try {
    final result = await operation();
    return Right(result);
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'weak-password': return Left(WeakPasswordFailure());
      case 'email-already-in-use': return Left(EmailAlreadyInUseFailure());
      case 'invalid-email': return Left(InvalidEmailFailure());
      case 'invalid-credential': return Left(InvalidCredentialFailure());
      default: return Left(GeneralFailure());
    }
  } on EmailAlreadyInUseException {
    return Left(EmailAlreadyInUseFailure());
  } on WeakPasswordException {
    return Left(WeakPasswordFailure());
  } on InvalidEmailException {
    return Left(InvalidEmailFailure());
  } on InvalidCredentialException {
    return Left(InvalidCredentialFailure());
  } on UnauthorizedException {
    return Left(UnauthorizedFailure());
  } on NetworkException {
    return Left(NetworkFailure());
  } on ServerException {
    return Left(ServerFailure());
  } on FirebaseException catch (e) {
    switch (e.code) {
      case 'permission-denied': return Left(UnauthorizedFailure());
      case 'unavailable': return Left(NetworkFailure());
      default: return Left(ServerFailure());
    }
  } on TimeoutException {
    return Left(TimeoutFailure());
  } catch (e) {
    return Left(GeneralFailure());
  }
}