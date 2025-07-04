import 'package:intentions_flutter/models/follow.dart';
import 'package:intentions_flutter/utils/json.dart';

enum NotificationKind { follow }

class Notification {
  final NotificationKind kind;
  final int createdAt;

  const Notification({required this.kind, required this.createdAt});
}

class FollowNotificationUser {
  final String id;
  final String username;
  final String? image;

  const FollowNotificationUser({
    required this.id,
    required this.username,
    this.image,
  });

  factory FollowNotificationUser.fromJson(String id, Json json) {
    return FollowNotificationUser(
      id: id,
      username: json['username'],
      image: json['image'],
    );
  }
}

class FollowNotification extends Notification {
  final FollowNotificationUser fromUser;
  final FollowNotificationUser toUser;
  final FollowStatus status;

  const FollowNotification({
    required this.fromUser,
    required this.toUser,
    required this.status,
    required super.createdAt,
  }) : super(kind: NotificationKind.follow);

  factory FollowNotification.fromJson(Json json) {
    return FollowNotification(
      fromUser: FollowNotificationUser.fromJson(
        json['data']['fromUserId'],
        json['data']['fromUser'],
      ),
      toUser: FollowNotificationUser.fromJson(
        json['data']['toUserId'],
        json['data']['toUser'],
      ),
      status: json['data']['status'] == 'pending'
          ? FollowStatus.pending
          : FollowStatus.accepted,
      createdAt: json['createdAt'],
    );
  }
}
