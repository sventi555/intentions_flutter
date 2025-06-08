import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/follow.dart';

final followsProvider = FutureProvider.family<List<Follow>, String>((
  ref,
  toUser,
) async {
  final follows = await firebase.db.collection('follows/$toUser/from').get();

  return follows.docs.map((follow) => Follow.fromJson(follow.data())).toList();
});
