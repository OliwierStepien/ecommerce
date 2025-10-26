import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/exception/handle_firestore_exception.dart';
import 'package:mealapp/data/auth/model/user_creation_req.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealapp/data/auth/model/user_signin_req.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthService {
  Future<String> signup(UserCreationReq user);
  Future<String> signin(UserSigninReq user);
  Future<String> sendPasswordResetEmail(String email);
  Future<String> signout();
  Future<bool> isLoggedIn();
  Future<Map<String, dynamic>> getUser();
}

class FirebaseAuthServiceImpl extends FirebaseAuthService {
  @override
  Future<String> signup(UserCreationReq user) async {
    return handleFirestoreException(() async {
      debugLog('[FIREBASE] signup ${user.email}');
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

      debugLog('[FIREBASE] signup success uid=${returnedData.user!.uid}');
      return 'Konto zostało utworzone';
    });
  }

  @override
  Future<String> signin(UserSigninReq user) async {
    return handleFirestoreException(() async {
      debugLog('[FIREBASE] signin attempt for ${user.email}');
      final creds = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: user.email,
            password: user.password!,
          )
          .timeout(const Duration(seconds: 15));

      debugLog('[FIREBASE] signin success -> uid=${creds.user?.uid}');
      return 'Logowanie zakończone sukcesem';
    });
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    return handleFirestoreException(() async {
      debugLog('[FIREBASE] reset password for $email');
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 15));
      return 'Email z instrukcją resetu hasła został wysłany';
    });
  }

  @override
  Future<String> signout() async {
    return handleFirestoreException(() async {
      debugLog('[FIREBASE] signout()');
      await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 15));
      return 'Zostałeś wylogowany';
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    debugLog('[FIREBASE] isLoggedIn? -> ${user != null}, uid=${user?.uid}');
    return user != null;
  }

  @override
  Future<Map<String, dynamic>> getUser() async {
    return handleFirestoreException(() async {
      final currentUser = FirebaseAuth.instance.currentUser;
      debugLog('[FIREBASE] getUser uid=${currentUser?.uid}');
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .get();

      final data = snap.data();
      if (data == null) {
        debugLog('[FIREBASE] getUser: brak dokumentu!');
        throw Exception('Użytkownik nie znaleziony');
      }

      debugLog('[FIREBASE] getUser success for ${data['email']}');
      return {
        'userId': currentUser!.uid, // zawsze dodaj uid
        ...data,
      };
    });
  }
}