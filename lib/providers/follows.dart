import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/providers/auth_user.dart';

final followsToUserProvider = FutureProvider.family<List<Follow>, String?>((
  ref,
  toUser,
) async {
  if (toUser == null) {
    return [];
  }

  final follows = await firebase.db.collection('follows/$toUser/from').get();

  return follows.docs.map((follow) => Follow.fromJson(follow.data())).toList();
});

enum RespondAction { accept, decline }

Future<void> respondToFollow(Ref ref, RespondAction action) async {
  final user = ref.read(authUserProvider).user;
  final token = await user?.getIdToken();

  await http.post(
    Uri.http('localhost:3001', '/posts'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({
      'action': action == RespondAction.accept ? 'accept' : 'decline',
    }),
  );
}

final respondToFollowProvider = Provider((ref) {
  return (RespondAction action) async {
    await respondToFollow(ref, action);
  };
});
