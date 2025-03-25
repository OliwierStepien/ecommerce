import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthFirebaseService {
  Future<String> signup(UserCreationReq user);
  Future<String> signin(UserSigninReq user);
  Future<String> sendPasswordResetEmail(String email);
  Future<String> signout();
  Future<bool> isLoggedIn();
  Future<Map<String, dynamic>> getUser();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<String> signup(UserCreationReq user) async {
    return handleFirestoreException(() async {
      final returnedData = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          )
          .timeout(const Duration(seconds: 15));

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(returnedData.user!.uid)
          .set({
        'firstName': user.firstName,
        'email': user.email,
      }).timeout(const Duration(seconds: 15));

      return 'Konto zostało utworzone';
    });
  }

  @override
  Future<String> signin(UserSigninReq user) async {
    return handleFirestoreException(() async {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: user.email,
            password: user.password!,
          )
          .timeout(const Duration(seconds: 15));

      return 'Logowanie zakończone sukcesem';
    });
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    return handleFirestoreException(() async {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 15));

      return 'Email z instrukcją resetu hasła został wysłany';
    });
  }

  @override
  Future<String> signout() async {
    return handleFirestoreException(() async {
      await FirebaseAuth.instance
          .signOut()
          .timeout(const Duration(seconds: 15));
      return 'Zostałeś wylogowany';
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    return handleFirestoreException(() async {
      return FirebaseAuth.instance.currentUser != null;
    });
  }

  @override
  Future<Map<String, dynamic>> getUser() async {
    return handleFirestoreException(() async {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .get()
          .then((value) => value.data());

      if (userData == null) {
        throw Exception('Użytkownik nie znaleziony');
      }

      return userData;
    });
  }
}
