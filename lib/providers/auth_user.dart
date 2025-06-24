import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';

class AuthUserNotifier extends AsyncNotifier<User?> {
  @override
  build() async {
    final stream = firebase.auth.authStateChanges();

    bool isFirst = true;
    final completer = Completer<User?>();

    stream.listen((u) {
      if (isFirst) {
        completer.complete(u);
        isFirst = false;
      } else {
        state = AsyncValue.data(u);
      }
    });

    return completer.future;
  }
}

final authUserProvider = AsyncNotifierProvider(() => AuthUserNotifier());
