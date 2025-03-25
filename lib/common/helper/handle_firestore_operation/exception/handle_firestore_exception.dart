import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/exception.dart';

Future<T> handleFirestoreException<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'weak-password': throw WeakPasswordException();
      case 'email-already-in-use': throw EmailAlreadyInUseException();
      case 'invalid-email': throw InvalidEmailException();
      case 'invalid-credential': 
      case 'user-not-found':
      case 'user-disabled': throw InvalidCredentialException();
      default: throw GeneralException();
    }
  } on FirebaseException catch (e) {
    switch (e.code) {
      case 'permission-denied': throw UnauthorizedException();
      case 'unavailable':
      case 'resource-exhausted': throw NetworkException();
      default: throw ServerException();
    }
  } on TimeoutException {
    throw TimeoutException();
  } catch (e) {
    throw GeneralException();
  }
}