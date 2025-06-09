import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';

final imageUrlProvider = FutureProvider.family<String?, String?>((
  ref,
  imagePath,
) async {
  if (imagePath == null) {
    return null;
  }

  return firebase.storage.ref().child(imagePath).getDownloadURL();
});
