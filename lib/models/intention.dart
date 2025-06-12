class IntentionUser {
  final String username;
  final String? image;

  const IntentionUser({required this.username, this.image});

  factory IntentionUser.fromJson(Map<String, dynamic> json) {
    return IntentionUser(username: json['username'], image: json['image']);
  }
}

class Intention {
  final String id;
  final String userId;
  final IntentionUser user;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int postCount;

  const Intention({
    required this.id,
    required this.userId,
    required this.user,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.postCount,
  });

  factory Intention.fromJson(String id, Map<String, dynamic> json) {
    return Intention(
      id: id,
      userId: json['userId'],
      user: IntentionUser.fromJson(json['user']),
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      postCount: json['postCount'],
    );
  }
}
