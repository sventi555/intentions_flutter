import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/providers/auth_user.dart';

final followsToMeProvider = FutureProvider<List<Follow>>((ref) async {
  final user = await ref.watch(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to get follows to self');
  }

  final follows = await firebase.db
      .collection('follows/${user.uid}/from')
      .get();

  return follows.docs
      .map((follow) => Follow.fromJson(follow.id, follow.data()))
      .toList();
});

Future<void> followUser(Ref ref, String userId) async {
  final user = await ref.read(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to follow user');
  }

  final token = await user.getIdToken();

  await http.post(
    Uri.parse('${ApiConfig.baseUrl}/follows/$userId'),
    headers: {'Authorization': token ?? ''},
  );
}

enum RespondAction { accept, decline }

class RespondToFollowBody {
  final RespondAction action;

  const RespondToFollowBody({required this.action});
}

Future<void> respondToFollow(
  Ref ref,
  String userId,
  RespondToFollowBody body,
) async {
  final user = await ref.read(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to respond to follow');
  }
  final token = await user.getIdToken();

  await http.post(
    Uri.parse('${ApiConfig.baseUrl}/follows/respond/$userId'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({
      'action': body.action == RespondAction.accept ? 'accept' : 'decline',
    }),
  );
}

final respondToFollowProvider = Provider((ref) {
  return (String userId, RespondToFollowBody body) async {
    await respondToFollow(ref, userId, body);
  };
});
