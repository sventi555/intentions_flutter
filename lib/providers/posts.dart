import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/post.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/intentions.dart';

final postsProvider = FutureProvider.family<List<Post>, String>((
  ref,
  userId,
) async {
  // user to clear cache when user signs out
  ref.watch(authUserProvider);

  final posts = await firebase.db
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .get();

  return posts.docs.map((d) => Post.fromJson(d.id, d.data())).toList();
});

final feedProvider = FutureProvider<List<Post>>((ref) async {
  final user = await ref.watch(authUserProvider.future);

  if (user == null) {
    return [];
  }

  final feed = await firebase.db
      .collection('users/${user.uid}/feed')
      .orderBy('createdAt', descending: true)
      .get();

  return feed.docs.map((d) => Post.fromJson(d.id, d.data())).toList();
});

final intentionPostsProvider = FutureProvider.family<List<Post>, String>((
  ref,
  intentionId,
) async {
  // user to clear cache when user signs out
  ref.watch(authUserProvider);

  final intention = await ref.watch(intentionProvider(intentionId).future);

  final posts = await firebase.db
      .collection('posts')
      // needed to appease firestore rule logic
      .where('userId', isEqualTo: intention.userId)
      .where('intentionId', isEqualTo: intentionId)
      .orderBy('createdAt', descending: true)
      .get();

  return posts.docs.map((doc) => Post.fromJson(doc.id, doc.data())).toList();
});

class CreatePostBody {
  final String intentionId;
  final String? description;
  final String? image;

  const CreatePostBody({
    required this.intentionId,
    this.description,
    this.image,
  });
}

Future<void> createPost(Ref ref, CreatePostBody body) async {
  final user = await ref.read(authUserProvider.future);
  if (user == null) {
    throw StateError('must be signed in to create post');
  }

  final token = await user.getIdToken();

  await http.post(
    Uri.parse('${ApiConfig.baseUrl}/posts'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({
      'intentionId': body.intentionId,
      'description': body.description,
      ...body.image != null ? {'image': body.image} : {},
    }),
  );

  ref.invalidate(feedProvider);
  ref.invalidate(postsProvider(user.uid));
  ref.invalidate(intentionPostsProvider(body.intentionId));
  invalidateIntentions(ref, user.uid);
}

final createPostProvider = Provider((ref) {
  return (CreatePostBody body) async {
    await createPost(ref, body);
  };
});
