import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// firebase auth class initialize
/// @author : surendra
/// @creationDate :13-Dec-2019
abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// signIn function
  Future<String> signIn(String email, String password) async {
    AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return authResult.user.uid;
  }

  /// signUp function
  Future<String> signUp(String email, String password) async {
    AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return authResult.user.uid;
  }

  /// get current login user function
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  /// signOut function
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
