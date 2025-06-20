import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/notifications.dart';
import 'package:intentions_flutter/providers/posts.dart';

final followFromMeProvider = FutureProvider.family<Follow?, String>((
  ref,
  toUserId,
) async {
  final authUser = await ref.watch(authUserProvider.future);
  if (authUser == null) {
    throw StateError('must be signed in to get follow from self');
  }

  final follow = await firebase.db
      .collection('follows/$toUserId/from')
      .doc(authUser.uid)
      .get();

  final followData = follow.data();
  if (followData == null) {
    return null;
  }

  return Follow.fromJson(authUser.uid, followData);
});

Future<void> followUser(Ref ref, String userId) async {
  final user = await ref.read(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to follow user');
  }

  final token = await user.getIdToken();

  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/follows/$userId'),
    headers: {'Authorization': token ?? ''},
  );

  // only need to update feed immediately if followed user is public
  final resBody = jsonDecode(res.body);
  if (resBody['status'] == 'accepted') {
    ref.invalidate(feedProvider);
  }

  ref.invalidate(followFromMeProvider(userId));
}

final followUserProvider = Provider((ref) {
  return (String userId) async {
    await followUser(ref, userId);
  };
});

enum RespondAction { accept, decline }

class RespondToFollowBody {
  final RespondAction action;

  const RespondToFollowBody({required this.action});
}

Future<void> unfollowUser(Ref ref, String userId) async {
  final user = await ref.read(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to respond to follow');
  }
  final token = await user.getIdToken();

  await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/follows/$userId'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({'direction': 'to'}),
  );

  ref.invalidate(followFromMeProvider(userId));
  ref.invalidate(feedProvider);
}

final unfollowUserProvider = Provider((ref) {
  return (String userId) async {
    await unfollowUser(ref, userId);
  };
});

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

  ref.invalidate(notificationsProvider);
}

final respondToFollowProvider = Provider((ref) {
  return (String userId, RespondToFollowBody body) async {
    await respondToFollow(ref, userId, body);
  };
});
