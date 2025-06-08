import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/user.dart';

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
