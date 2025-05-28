import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthUserNotifier extends ChangeNotifier {
  User? user;

  AuthUserNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      this.user = user;
      notifyListeners();
    });
  }
}
