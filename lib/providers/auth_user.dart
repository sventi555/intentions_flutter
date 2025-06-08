import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';

class AuthUserState {
  final bool loading;
  final User? user;

  const AuthUserState({this.loading = true, this.user});
}

class AuthUserNotifier extends Notifier<AuthUserState> {
  @override
  build() {
    firebase.auth.authStateChanges().listen((u) {
      state = AuthUserState(loading: false, user: u);
    });

    return AuthUserState();
  }
}

final authUserProvider = NotifierProvider(() => AuthUserNotifier());
