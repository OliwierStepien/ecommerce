import 'package:dartz/dartz.dart';
import 'package:mealapp/data/auth/models/user_creation_req.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> sendPasswordResetEmail(String email);
  Future<Either> signout();
  Future<bool> isLoggedIn();
  Future<Either> getUser();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> signup(UserCreationReq user) async {
    try {
      final returnedData =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(returnedData.user!.uid)
          .set({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
      });

      return const Right('Konto zostało utworzone');
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'Hasło jest zbyt słabe';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ten email jest już zajęty.';
      }
      return Left(message);
    } catch (e) {
      return const Left('Coś poszło nie tak');
    }
  }

  @override
  Future<Either> signin(UserSigninReq user) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email,
        password: user.password!,
      );

      return const Right('Logowanie zakończone sukcesem');
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'Nie znaleziono uzytkownika z takim adresem email';
      } else if (e.code == 'invalid-credential') {
        message = 'Podano błędne hasło';
      }
      return Left(message);
    } catch (e) {
      return const Left('Coś poszło nie tak');
    }
  }

  @override
  Future<Either> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return const Right('Email z instrukcją resetu hasła został wysłany');
    } catch (e) {
      return const Left('Proszę spróbować ponownie');
    }
  }

  @override
  Future<Either> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Right('Uzytkownik został wylogowany');
    } catch (e) {
      return const Left('Proszę spróbować ponownie');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<Either> getUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .get()
          .then((value) => value.data());
      return Right(userData);
    } catch (e) {
      return const Left('Proszę spróbować ponownie');
    }
  }
}
