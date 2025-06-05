import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';

final authUserProvider = StreamProvider((ref) {
  return firebase.auth.authStateChanges();
});
