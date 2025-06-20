import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/models/notification.dart';
import 'package:intentions_flutter/providers/auth_user.dart';

final notificationsProvider = FutureProvider<List<Notification>>((ref) async {
  final authUser = await ref.watch(authUserProvider.future);
  if (authUser == null) {
    return [];
  }

  final notifications = await firebase.db
      .collection('users/${authUser.uid}/notifications')
      .orderBy('createdAt', descending: true)
      .get();

  return notifications.docs.map((notification) {
    if (notification.data()['kind'] == 'follow') {
      return FollowNotification.fromJson(notification.data());
    }
    throw Exception('encountered unknown notification kind');
  }).toList();
});
