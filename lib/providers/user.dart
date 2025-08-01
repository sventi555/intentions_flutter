import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intentions_flutter/api_config.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/user.dart';
import 'package:intentions_flutter/providers/auth_user.dart';
import 'package:intentions_flutter/providers/posts.dart';

final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final user = await firebase.db.collection('users').doc(userId).get();

  final data = user.data();
  if (data == null) {
    throw Exception('could not fetch user');
  }

  return User.fromJson(user.id, data);
});

final userSearchProvider = FutureProvider.family<List<User>, String?>((
  ref,
  username,
) async {
  if (username == null) {
    return [];
  }

  final users = await firebase.db
      .collection('users')
      .where('username', isEqualTo: username)
      .get();

  return users.docs.map((user) => User.fromJson(user.id, user.data())).toList();
});

class UpdateUserBody {
  final String? image;

  const UpdateUserBody({this.image});
}

Future<void> updateUser(Ref ref, UpdateUserBody body) async {
  final authUser = await ref.read(authUserProvider.future);
  final user = await ref.read(userProvider(authUser?.uid ?? '').future);

  if (authUser == null) {
    throw StateError('must be signed in to update user');
  }

  final token = await authUser.getIdToken();

  await http.patch(
    Uri.parse('${ApiConfig.baseUrl}/users'),
    headers: {'Authorization': token ?? '', 'Content-Type': 'application/json'},
    body: jsonEncode({
      ...body.image != null ? {'image': body.image} : {},
    }),
  );

  ref.invalidate(userProvider(authUser.uid));
  ref.invalidate(userSearchProvider(user.username));
  ref.invalidate(postsProvider(authUser.uid));
  ref.invalidate(feedProvider);
}

final updateUserProvider = Provider((ref) {
  return (UpdateUserBody body) async {
    await updateUser(ref, body);
  };
});
