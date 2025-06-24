import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/providers/auth_user.dart';

final imageUrlProvider = FutureProvider.family<String?, String?>((
  ref,
  imagePath,
) async {
  // user to clear cache when user signs out
  ref.watch(authUserProvider);

  if (imagePath == null) {
    return null;
  }

  return firebase.storage.ref().child(imagePath).getDownloadURL();
});
