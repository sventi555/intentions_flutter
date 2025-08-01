import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/post.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/intentions.dart';
import 'package:intentions_flutter/providers/paged.dart';
import 'package:intentions_flutter/utils/json.dart';

class PostsNotifier extends FamilyPagedNotifier<Post, String> {
  @override
  Post itemFromJson(String id, Json json) {
    return Post.fromJson(id, json);
  }

  @override
  FutureOr<Query<Json>?> itemsQuery(String userId) {
    // user to clear cache when user signs out
    ref.watch(authUserProvider);

    return firebase.db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
  }
}

final postsProvider = AsyncNotifierProvider.family(() => PostsNotifier());

class FeedNotifier extends PagedNotifier<Post> {
  @override
  Post itemFromJson(String id, Json json) {
    return Post.fromJson(id, json);
  }

  @override
  FutureOr<Query<Json>?> itemsQuery() async {
    final user = await ref.watch(authUserProvider.future);

    if (user == null) {
      return null;
    }

    return firebase.db
        .collection('users/${user.uid}/feed')
        .orderBy('createdAt', descending: true);
  }
}

final feedProvider = AsyncNotifierProvider(() => FeedNotifier());

class IntentionsPostsNotifier extends FamilyPagedNotifier<Post, String> {
  @override
  Post itemFromJson(String id, Json json) {
    return Post.fromJson(id, json);
  }

  @override
  FutureOr<Query<Json>?> itemsQuery(String intentionId) async {
    // user to clear cache when user signs out
    ref.watch(authUserProvider);

    final intention = await ref.watch(intentionProvider(intentionId).future);

    return firebase.db
        .collection('posts')
        // needed to appease firestore rule logic
        .where('userId', isEqualTo: intention.userId)
        .where('intentionId', isEqualTo: intentionId)
        .orderBy('createdAt', descending: true);
  }
}

final intentionPostsProvider = AsyncNotifierProvider.family(
  () => IntentionsPostsNotifier(),
);

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
