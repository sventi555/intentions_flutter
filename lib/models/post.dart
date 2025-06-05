class PostUser {
  final String username;
  final String? image;

  const PostUser({required this.username, this.image});

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(username: json['username'], image: json['image']);
  }
}

class PostIntention {
  final String name;

  const PostIntention({required this.name});

  factory PostIntention.fromJson(Map<String, dynamic> json) {
    return PostIntention(name: json['name']);
  }
}

class Post {
  final String id;
  final String userId;
  final PostUser user;
  final String intentionId;
  final PostIntention intention;
  final int createdAt;
  final String? description;
  final String? image;

  const Post({
    required this.id,
    required this.userId,
    required this.user,
    required this.intentionId,
    required this.intention,
    required this.createdAt,
    this.description,
    this.image,
  });

  factory Post.fromJson(String id, Map<String, dynamic> json) {
    return Post(
      id: id,
      userId: json['userId'],
      user: PostUser.fromJson(json['user']),
      intentionId: json['intentionId'],
      intention: PostIntention.fromJson(json['intention']),
      createdAt: json['createdAt'],
      description: json['description'],
      image: json['image'],
    );
  }
}
