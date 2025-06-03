enum FollowStatus { pending, accepted }

class FollowUser {
  final String username;
  final String? image;

  const FollowUser({required this.username, this.image});

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(username: json['username'], image: json['image']);
  }
}

class Follow {
  final FollowStatus status;
  final FollowUser fromUser;
  final int createdAt;

  const Follow({
    required this.status,
    required this.fromUser,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      status: json['status'] == 'pending'
          ? FollowStatus.pending
          : FollowStatus.accepted,
      fromUser: FollowUser.fromJson(json['fromUser']),
      createdAt: json['createdAt'],
    );
  }
}
